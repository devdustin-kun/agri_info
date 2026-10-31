// Copy this file to config.js and fill in your own values.
// config.js is listed in .gitignore so your project URL is not committed.
// Supabase Dashboard > Project Settings > API
// Use the anon (public) key ONLY. Never put the service_role key in the browser.
// Row Level Security (security.sql) is what actually protects the data.
window.ENV = {
  SUPABASE_URL: "https://YOUR-PROJECT-ID.supabase.co",
  SUPABASE_ANON_KEY: "YOUR-ANON-PUBLIC-KEY"
};
