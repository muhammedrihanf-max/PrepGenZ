class SupabaseConfig {
  static const String supabaseUrl = "https://tgdfouokeiqsfbvllpaw.supabase.co"; 
  static const String supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRnZGZvdW9rZWlxc2ZidmxscGF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyODUwNzEsImV4cCI6MjA5NTg2MTA3MX0.f3D_xC0CHigdbM5Nnl9VOuQX_ey-GBb3ogXtj7qzGmE"; 

  static bool get isConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
