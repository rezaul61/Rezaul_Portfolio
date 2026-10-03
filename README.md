# Rezaul Islam Portfolio — public site + private admin (Supabase + GitHub Pages)

Public site:  https://YOUR-USERNAME.github.io/REPO/        (read-only for everyone)
Admin:        https://YOUR-USERNAME.github.io/REPO/admin/  (login required)

All content lives in Supabase (Postgres + Auth + Storage). GitHub Pages only serves the files.
Nothing important is stored in the browser.

## Step 1 — Create the backend (5 min)
1. Go to supabase.com, sign up, click **New project** (any name; save the database password; pick a nearby region).
2. Wait ~2 min. Open **SQL Editor -> New query**, paste ALL of `supabase/schema.sql`, click **Run**. It should say "Success".
3. Open **Project Settings -> API**. Copy **Project URL** and the **anon public** key.
   (Do NOT use or share the `service_role` key.)

## Step 2 — Create your admin account
1. Supabase -> **Authentication -> Users -> Add user -> Create new user**. Enter your email + a strong password, tick "Auto Confirm User".
2. Supabase -> **Authentication -> Sign In / Providers** (or Settings) -> turn **OFF "Allow new users to sign up"**, so nobody else can register.
3. SQL Editor -> new query, run (put YOUR email):
   `insert into public.admins(user_id) select id from auth.users where email = 'YOUR@EMAIL';`
   Only this account can ever edit.

## Step 3 — Add your keys
Open `config.js` in Notepad, replace the two values with your Project URL and anon key. Save.
(That is the only place any key goes. The anon key is meant to be public; the rules in schema.sql protect your data.)

## Step 4 — Put it on GitHub Pages
1. github.com -> **New repository** (public) -> name it e.g. `portfolio`.
2. **Add file -> Upload files**: drag in `index.html`, `config.js`, `.nojekyll`, the `admin` folder and the `supabase` folder (unzip first). Commit.
3. **Settings -> Pages -> Deploy from a branch -> main / (root) -> Save**. After ~1 min your URL appears there.
4. Supabase -> **Authentication -> URL Configuration**: set Site URL to your GitHub Pages address.

## Step 5 — First edit
1. Open `.../admin/`, sign in. Your current portfolio content is saved to the database automatically the first time ("Your content was saved to the database ✓").
2. Click the pencil to edit text; use + / x / arrows to add, delete, reorder; gear = name, links, photo, CV, lists; bold with the B button.
3. Every change shows "Saved & published ✓".

## Step 6 — Check it from another device
Open the public URL on your phone in a private/incognito tab. Change your biography in admin, wait 2 seconds, and the open phone page updates by itself (or refresh). Clearing browser data changes nothing.

## Notes
- Hidden sections (Research Experience, Certifications, Conferences, Courses) appear only after you fill and unhide them (edit mode -> "Show section").
- Messages from the contact form appear in gear -> Inbox.
- Profile Visits = unique visitors per day.
- Backups: Supabase -> Database -> Backups, or export table `portfolio` as CSV.
