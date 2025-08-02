# Supabase Setup Guide

This guide will help you set up Supabase in your Flutter project.

## 1. Create a Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in to your account
3. Click "New Project"
4. Fill in the project details:
   - **Name**: GeoMentor
   - **Database Password**: Choose a strong password
   - **Region**: Select the closest region to your users
5. Click "Create new project"

## 2. Get Your Project Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project.supabase.co`)
   - **Anon public key** (starts with `eyJ...`)

## 3. Update Configuration

1. Open `lib/config/supabase_config.dart`
2. Replace the placeholder values with your actual credentials:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

## 4. Create Database Tables

In your Supabase dashboard, go to **SQL Editor** and run the following SQL:

### Users Table
```sql
CREATE TABLE users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view their own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON users
  FOR INSERT WITH CHECK (auth.uid() = id);
```

### Profiles Table (Optional)
```sql
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  username TEXT UNIQUE,
  avatar_url TEXT,
  bio TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Profiles are viewable by everyone" ON profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
```

## 5. Set Up Authentication

1. In your Supabase dashboard, go to **Authentication** → **Settings**
2. Configure your authentication settings:
   - **Site URL**: `http://localhost:3000` (for development)
   - **Redirect URLs**: Add your app's redirect URLs
   - **Email Templates**: Customize email templates if needed

## 6. Environment Variables (Optional)

For better security, you can use environment variables:

1. Create a `.env` file in your project root:
```
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

2. Update `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
}
```

3. Run your app with environment variables:
```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

## 7. Test the Integration

1. Run your app: `flutter run`
2. Try to sign up with a new email
3. Check your Supabase dashboard to see the new user
4. Try logging in with the created account

## 8. Additional Features

### Storage Setup
1. Go to **Storage** in your Supabase dashboard
2. Create a new bucket called `avatars`
3. Set the bucket to public or private as needed

### Real-time Features
The app is already set up to use Supabase's real-time features. You can:
- Listen to database changes
- Send real-time messages
- Sync data across devices

## 9. Troubleshooting

### Common Issues:

1. **"Invalid API key" error**
   - Check that you've copied the correct anon key
   - Make sure there are no extra spaces

2. **"Project not found" error**
   - Verify your project URL is correct
   - Check that your project is active

3. **Authentication not working**
   - Check your redirect URLs in Supabase settings
   - Verify email templates are configured

4. **Database permission errors**
   - Make sure Row Level Security policies are set up correctly
   - Check that the user is authenticated

## 10. Security Best Practices

1. **Never commit API keys** to version control
2. **Use environment variables** for production
3. **Set up proper RLS policies** for your tables
4. **Regularly rotate** your API keys
5. **Monitor your usage** in the Supabase dashboard

## 11. Next Steps

Now that Supabase is set up, you can:

1. **Add more tables** for your app's features
2. **Implement file uploads** using Supabase Storage
3. **Add real-time features** for live updates
4. **Set up email notifications** for user actions
5. **Add social authentication** (Google, GitHub, etc.)

## Support

If you encounter any issues:
1. Check the [Supabase documentation](https://supabase.com/docs)
2. Visit the [Supabase community](https://github.com/supabase/supabase/discussions)
3. Contact Supabase support for paid plans 