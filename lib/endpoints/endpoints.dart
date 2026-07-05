class Endpoints {
  // ============================================================
  // Supabase Config
  // ============================================================
  static const String supabaseUrl = 'https://grjynvqtzpzxnjamwhnu.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdyanludnF0enB6eG5qYW13aG51Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMyNTgxNjYsImV4cCI6MjA5ODgzNDE2Nn0.WP17BjeazXxOGjxuLOaBxRxkSxoKGYS40yxwAOH8E_A';

  // ============================================================
  // Table Names (dipakai di service layer)
  // ============================================================
  static const String tableProfiles = 'profiles';
  static const String tableProducts = 'products';
  static const String tableProductImages = 'product_images';
  static const String tableWishlists = 'wishlists';
  static const String tableChats = 'chats';
  static const String tableMessages = 'messages';
  static const String tableTransactions = 'transactions';

  // ============================================================
  // Storage Bucket Names
  // ============================================================
  static const String bucketProductImages = 'product-images';
  static const String bucketAvatars = 'avatars';
}
