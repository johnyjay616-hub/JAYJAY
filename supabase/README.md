# ConnectWorld Supabase setup

The ConnectWorld frontend is now wired to this Supabase project.

## One-time Supabase setup

1. Open the Supabase dashboard for your ConnectWorld project.
2. Go to **SQL Editor**.
3. Open this repository's `supabase/schema.sql`, copy the complete file, paste it into SQL Editor, and click **Run**.
   - This creates/updates the tables, Row Level Security policies, signup profile trigger, realtime tables, and the `connectworld-media` public storage bucket.
4. Go to **Authentication → Providers → Email** and make sure Email is enabled.
5. For easiest testing, you can turn off **Confirm email** temporarily. If email confirmation remains enabled, new users must confirm their email before their first login.
6. The browser app uses only the Supabase publishable key. Never add a service-role/secret key to GitHub.

## What the GitHub frontend now supports

- Email/password sign-up and login
- Password reset email
- Session-aware login/logout UI
- Automatic profile creation after signup
- Profile editing: name, username, country, bio, interests, avatar URL and cover URL
- Feed loaded from Supabase
- Text posts and image uploads
- Likes and comments
- People discovery by country and interest
- Friend requests and accepted friends
- Notifications
- One-to-one messages
- Realtime messages, notifications and feed refreshes

## Important

The Supabase publishable key is safe to use in a browser application. **Never commit a service-role or secret key.**

If the site shows an error after a database change, first rerun the complete `supabase/schema.sql` in the Supabase SQL Editor, then refresh the GitHub Pages site.