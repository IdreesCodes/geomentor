-- SIMPLE FIX: Remove the device time parameter and use server time but fix the calculation
-- Run this in your Supabase SQL Editor

-- 1. Drop all existing functions
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TEXT);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TEXT);
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION);

-- 2. Create simple function that works with the original 3 parameters
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
BEGIN
  -- Use server time but adjust for timezone difference
  check_in_time := NOW() AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Kolkata';
  check_date := DATE(check_in_time);
  
  -- Calculate target time (8:00 AM on the same date in local timezone)
  target_time := check_date + INTERVAL '8 hours';
  
  -- Calculate minutes late
  IF check_in_time > target_time THEN
    late_minutes := EXTRACT(EPOCH FROM (check_in_time - target_time)) / 60;
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
  
  -- Return result
  result := json_build_object(
    'status', 'success',
    'check_in_time', check_in_time,
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
  check_out_lng DOUBLE PRECISION
)
RETURNS JSON AS $$
DECLARE
  check_date DATE;
  work_hours DECIMAL(4,2);
  result JSON;
  check_out_time TIMESTAMP WITH TIME ZONE;
BEGIN
  check_out_time := NOW() AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Kolkata';
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

-- 4. Success message
SELECT 'SIMPLE FIX: Functions updated to use server time with timezone correction!' as status; 