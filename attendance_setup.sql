-- Clean attendance setup with Indian timezone
-- Run this in your Supabase SQL Editor

-- 1. Drop ALL existing functions to avoid conflicts
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TEXT);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TEXT);
DROP FUNCTION IF EXISTS get_current_month_attendance(UUID);
DROP FUNCTION IF EXISTS calculate_late_minutes(TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS get_monthly_attendance_summary(UUID, INTEGER, INTEGER);

-- 2. Drop existing policies
DROP POLICY IF EXISTS "Users can view their own attendance" ON attendance;
DROP POLICY IF EXISTS "Users can insert their own attendance" ON attendance;
DROP POLICY IF EXISTS "Users can update their own attendance" ON attendance;

-- 3. Create attendance table (if not exists)
CREATE TABLE IF NOT EXISTS attendance (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  check_in_time TIMESTAMP WITH TIME ZONE,
  check_out_time TIMESTAMP WITH TIME ZONE,
  check_in_latitude DOUBLE PRECISION,
  check_in_longitude DOUBLE PRECISION,
  check_out_latitude DOUBLE PRECISION,
  check_out_longitude DOUBLE PRECISION,
  status TEXT DEFAULT 'present',
  minutes_late INTEGER DEFAULT 0,
  total_work_hours DECIMAL(4,2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- 4. Enable RLS
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- 5. Create RLS policies
CREATE POLICY "Users can view their own attendance" ON attendance
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own attendance" ON attendance
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own attendance" ON attendance
  FOR UPDATE USING (auth.uid() = user_id);

-- 6. Create check-in function (3 parameters only)
CREATE OR REPLACE FUNCTION mark_check_in(
  user_uuid UUID,
  check_in_lat DOUBLE PRECISION,
  check_in_lng DOUBLE PRECISION
)
RETURNS JSON AS $$
DECLARE
  check_date DATE;
  late_minutes INTEGER;
  attendance_status TEXT;
  result JSON;
  target_time TIMESTAMP WITH TIME ZONE;
  check_in_time TIMESTAMP WITH TIME ZONE;
  current_hour INTEGER;
  current_minute INTEGER;
BEGIN
  -- Get current time in Indian timezone
  check_in_time := NOW() AT TIME ZONE 'Asia/Kolkata';
  check_date := DATE(check_in_time);
  
  -- Extract hour and minute from check-in time
  current_hour := EXTRACT(HOUR FROM check_in_time);
  current_minute := EXTRACT(MINUTE FROM check_in_time);
  
  -- Calculate minutes late: if after 8:00 AM, calculate minutes past 8:00
  IF current_hour >= 8 THEN
    -- Calculate total minutes since midnight, then subtract 8 hours (480 minutes)
    late_minutes := (current_hour * 60 + current_minute) - 480;
  ELSE
    late_minutes := 0;
  END IF;
  
  -- Ensure late_minutes is not negative
  IF late_minutes < 0 THEN
    late_minutes := 0;
  END IF;
  
  -- Determine status
  IF late_minutes > 0 THEN
    attendance_status := 'late';
  ELSE
    attendance_status := 'present';
  END IF;
  
  -- Insert or update attendance record
  INSERT INTO attendance (
    user_id, 
    date, 
    check_in_time, 
    check_in_latitude, 
    check_in_longitude, 
    status, 
    minutes_late
  ) VALUES (
    user_uuid, 
    check_date, 
    check_in_time, 
    check_in_lat, 
    check_in_lng, 
    attendance_status, 
    late_minutes
  )
  ON CONFLICT (user_id, date) 
  DO UPDATE SET
    check_in_time = EXCLUDED.check_in_time,
    check_in_latitude = EXCLUDED.check_in_latitude,
    check_in_longitude = EXCLUDED.check_in_longitude,
    status = EXCLUDED.status,
    minutes_late = EXCLUDED.minutes_late,
    updated_at = NOW();
  
  -- Return result with debug info
  result := json_build_object(
    'status', 'success',
    'check_in_time', check_in_time,
    'late_minutes', late_minutes,
    'attendance_status', attendance_status,
    'debug_info', json_build_object(
      'check_date', check_date,
      'current_hour', current_hour,
      'current_minute', current_minute,
      'total_minutes_since_midnight', current_hour * 60 + current_minute,
      'target_minutes_since_midnight', 480,
      'calculation', (current_hour * 60 + current_minute) - 480
    )
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Create check-out function (3 parameters only)
CREATE OR REPLACE FUNCTION mark_check_out(
  user_uuid UUID,
  check_out_lat DOUBLE PRECISION,
  check_out_lng DOUBLE PRECISION
)
RETURNS JSON AS $$
DECLARE
  check_date DATE;
  work_hours DECIMAL(4,2);
  result JSON;
  check_out_time TIMESTAMP WITH TIME ZONE;
BEGIN
  check_out_time := NOW() AT TIME ZONE 'Asia/Kolkata';
  check_date := DATE(check_out_time);
  
  -- Calculate work hours
  SELECT 
    CASE 
      WHEN check_in_time IS NOT NULL 
      THEN EXTRACT(EPOCH FROM (check_out_time - check_in_time)) / 3600
      ELSE 0 
    END
  INTO work_hours
  FROM attendance 
  WHERE user_id = user_uuid AND date = check_date;
  
  -- Update attendance record
  UPDATE attendance 
  SET 
    check_out_time = check_out_time,
    check_out_latitude = check_out_lat,
    check_out_longitude = check_out_lng,
    total_work_hours = work_hours,
    updated_at = NOW()
  WHERE user_id = user_uuid AND date = check_date;
  
  -- Return result
  result := json_build_object(
    'status', 'success',
    'check_out_time', check_out_time,
    'work_hours', work_hours
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 8. Success message
SELECT '✅ Attendance functions updated successfully with Indian timezone!' as status; 