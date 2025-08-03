-- Simple Fix: Treat Device Time as Local Time
-- Run this in your Supabase SQL Editor

-- 1. Drop existing functions
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION);

-- 2. Create simple function that treats device time as local time
CREATE OR REPLACE FUNCTION mark_check_in(
  user_uuid UUID,
  check_in_lat DOUBLE PRECISION,
  check_in_lng DOUBLE PRECISION,
  device_check_in_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS JSON AS $$
DECLARE
  check_date DATE;
  late_minutes INTEGER;
  attendance_status TEXT;
  result JSON;
  target_time TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Treat device time as local time (no timezone conversion)
  check_date := DATE(device_check_in_time);
  
  -- Calculate target time (8:00 AM on the same date)
  target_time := DATE(device_check_in_time) + INTERVAL '8 hours';
  
  -- Calculate minutes late
  IF device_check_in_time > target_time THEN
    late_minutes := EXTRACT(EPOCH FROM (device_check_in_time - target_time)) / 60;
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
    device_check_in_time, 
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
    'check_in_time', device_check_in_time,
    'late_minutes', late_minutes,
    'attendance_status', attendance_status
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Create simple function for check-out
CREATE OR REPLACE FUNCTION mark_check_out(
  user_uuid UUID,
  check_out_lat DOUBLE PRECISION,
  check_out_lng DOUBLE PRECISION,
  device_check_out_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS JSON AS $$
DECLARE
  check_date DATE;
  work_hours DECIMAL(4,2);
  result JSON;
BEGIN
  check_date := DATE(device_check_out_time);
  
  -- Calculate work hours
  SELECT 
    CASE 
      WHEN check_in_time IS NOT NULL 
      THEN EXTRACT(EPOCH FROM (device_check_out_time - check_in_time)) / 3600
      ELSE 0 
    END
  INTO work_hours
  FROM attendance 
  WHERE user_id = user_uuid AND date = current_date;
  
  -- Update attendance record
  UPDATE attendance 
  SET 
    check_out_time = device_check_out_time,
    check_out_latitude = check_out_lat,
    check_out_longitude = check_out_lng,
    total_work_hours = work_hours,
    updated_at = NOW()
  WHERE user_id = user_uuid AND date = current_date;
  
  -- Return result
  result := json_build_object(
    'status', 'success',
    'check_out_time', device_check_out_time,
    'work_hours', work_hours
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Success message
SELECT 'Simple attendance functions with device time support completed successfully!' as status; 