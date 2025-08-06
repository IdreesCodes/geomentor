-- Fixed Attendance System Database Setup
-- Run this in your Supabase SQL Editor

-- 1. Drop existing functions
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION);

-- 2. Create function that properly handles local time string
CREATE OR REPLACE FUNCTION mark_check_in(
  user_uuid UUID,
  check_in_lat DOUBLE PRECISION,
  check_in_lng DOUBLE PRECISION,
  device_check_in_time TEXT DEFAULT NOW()::TEXT
)
RETURNS JSON AS $$
DECLARE
  check_date DATE;
  late_minutes INTEGER;
  attendance_status TEXT;
  result JSON;
  target_time TIMESTAMP;
  local_check_in_time TIMESTAMP;
BEGIN
  -- Parse the local time string (format: YYYY-MM-DDTHH:MM:SS)
  local_check_in_time := device_check_in_time::TIMESTAMP;
  check_date := DATE(local_check_in_time);
  
  -- Calculate target time (8:00 AM on the same date)
  target_time := check_date + INTERVAL '8 hours';
  
  -- Calculate minutes late
  IF local_check_in_time > target_time THEN
    late_minutes := EXTRACT(EPOCH FROM (local_check_in_time - target_time)) / 60;
  ELSE
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
    local_check_in_time, 
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
  
  -- Return result
  result := json_build_object(
    'status', 'success',
    'check_in_time', local_check_in_time,
    'late_minutes', late_minutes,
    'attendance_status', attendance_status
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create fixed function for check-out (resolves ambiguous column reference)
CREATE OR REPLACE FUNCTION mark_check_out(
  user_uuid UUID,
  check_out_lat DOUBLE PRECISION,
  check_out_lng DOUBLE PRECISION,
  device_check_out_time TEXT DEFAULT NOW()::TEXT
)
RETURNS JSON AS $$
DECLARE
  check_date DATE;
  work_hours DECIMAL(4,2);
  result JSON;
  local_check_out_time TIMESTAMP;
  existing_check_in_time TIMESTAMP;
BEGIN
  -- Parse the local time string
  local_check_out_time := device_check_out_time::TIMESTAMP;
  check_date := DATE(local_check_out_time);
  
  -- Get existing check-in time to calculate work hours
  SELECT check_in_time INTO existing_check_in_time
  FROM attendance 
  WHERE user_id = user_uuid AND date = check_date;
  
  -- Calculate work hours
  IF existing_check_in_time IS NOT NULL THEN
    work_hours := EXTRACT(EPOCH FROM (local_check_out_time - existing_check_in_time)) / 3600;
  ELSE
    work_hours := 0;
  END IF;
  
  -- Update attendance record
  UPDATE attendance 
  SET 
    check_out_time = local_check_out_time,
    check_out_latitude = check_out_lat,
    check_out_longitude = check_out_lng,
    total_work_hours = work_hours,
    updated_at = NOW()
  WHERE user_id = user_uuid AND date = check_date;
  
  -- Return result
  result := json_build_object(
    'status', 'success',
    'check_out_time', local_check_out_time,
    'work_hours', work_hours
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Success message
SELECT 'Fixed attendance functions completed successfully!' as status; 