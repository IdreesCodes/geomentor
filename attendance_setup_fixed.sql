-- Fixed Attendance System Database Setup with Proper Timezone Handling
-- Run this in your Supabase SQL Editor

-- 1. Drop existing functions
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION, TIMESTAMP WITH TIME ZONE);
DROP FUNCTION IF EXISTS mark_check_in(UUID, DOUBLE PRECISION, DOUBLE PRECISION);
DROP FUNCTION IF EXISTS mark_check_out(UUID, DOUBLE PRECISION, DOUBLE PRECISION);

-- 2. Create updated function to mark check-in with proper timezone handling
CREATE OR REPLACE FUNCTION mark_check_in(
  user_uuid UUID,
  check_in_lat DOUBLE PRECISION,
  check_in_lng DOUBLE PRECISION,
  device_check_in_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS JSON AS $$
DECLARE
  current_date DATE;
  late_minutes INTEGER;
  attendance_status TEXT;
  result JSON;
  local_check_in_time TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Convert device time to local timezone (assuming device is in local timezone)
  -- The device sends UTC time, but we need to interpret it as local time
  local_check_in_time := device_check_in_time AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Karachi';
  current_date := DATE(local_check_in_time);
  
  -- Calculate if late using local time (8:00 AM target)
  late_minutes := calculate_late_minutes(local_check_in_time);
  
  -- Determine status
  IF late_minutes > 0 THEN
    attendance_status := 'late';
  ELSE
    attendance_status := 'present';
  END IF;
  
  -- Insert or update attendance record using local time
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
    current_date, 
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

-- 3. Create updated function to mark check-out with proper timezone handling
CREATE OR REPLACE FUNCTION mark_check_out(
  user_uuid UUID,
  check_out_lat DOUBLE PRECISION,
  check_out_lng DOUBLE PRECISION,
  device_check_out_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
)
RETURNS JSON AS $$
DECLARE
  current_date DATE;
  work_hours DECIMAL(4,2);
  result JSON;
  local_check_out_time TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Convert device time to local timezone
  local_check_out_time := device_check_out_time AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Karachi';
  current_date := DATE(local_check_out_time);
  
  -- Calculate work hours using local time
  SELECT 
    CASE 
      WHEN check_in_time IS NOT NULL 
      THEN EXTRACT(EPOCH FROM (local_check_out_time - check_in_time)) / 3600
      ELSE 0 
    END
  INTO work_hours
  FROM attendance 
  WHERE user_id = user_uuid AND date = current_date;
  
  -- Update attendance record
  UPDATE attendance 
  SET 
    check_out_time = local_check_out_time,
    check_out_latitude = check_out_lat,
    check_out_longitude = check_out_lng,
    total_work_hours = work_hours,
    updated_at = NOW()
  WHERE user_id = user_uuid AND date = current_date;
  
  -- Return result
  result := json_build_object(
    'status', 'success',
    'check_out_time', local_check_out_time,
    'work_hours', work_hours
  );
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Update the calculate_late_minutes function to handle timezone properly
CREATE OR REPLACE FUNCTION calculate_late_minutes(check_in_time TIMESTAMP WITH TIME ZONE)
RETURNS INTEGER AS $$
DECLARE
  target_time TIMESTAMP WITH TIME ZONE;
  late_minutes INTEGER;
BEGIN
  -- Set target check-in time to 8:00 AM on the same date in local timezone
  target_time := DATE(check_in_time) + INTERVAL '8 hours';
  
  -- Calculate minutes late
  IF check_in_time > target_time THEN
    late_minutes := EXTRACT(EPOCH FROM (check_in_time - target_time)) / 60;
  ELSE
    late_minutes := 0;
  END IF;
  
  RETURN late_minutes;
END;
$$ LANGUAGE plpgsql;

-- 5. Success message
SELECT 'Fixed attendance functions with proper timezone handling completed successfully!' as status; 