# Supabase setup

The website uses Supabase for admin sign-in and its shared enquiry inbox. Do not put a Supabase service-role key in the website.

1. Create a Supabase project and open its SQL Editor.
2. Run the contents of `supabase-setup.sql`.
3. In **Authentication → Users**, add your admin user with your own email and a strong password. Confirm the user if Supabase requires it.
4. In the SQL Editor, authorize that user by replacing the email below and running the query:

   ```sql
   insert into public.admin_users (user_id)
   select id from auth.users where email = 'YOUR_ADMIN_EMAIL';
   ```

5. In **Project Settings → API**, copy the publishable/anon key. The Project URL is already set in `index.html`; replace `YOUR_SUPABASE_ANON_KEY` with the publishable key. The publishable/anon key is intended for browser use; database row-level security in the SQL file protects the inbox.
6. In Supabase **Authentication → Providers → Email**, keep email/password sign-in enabled and disable public sign-ups. Add additional admin users in Authentication, then add each user's ID to `public.admin_users` using the same query.
7. Deploy the contents of this folder to Netlify. Public form submissions will then appear in the website Admin Portal after an authorized admin signs in.

The portal replies using the visitor's email app through a `mailto:` link; sending replies from the website would require a separately configured email service.
