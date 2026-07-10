-- ============================================================
-- REUSEU — SUPABASE DATABASE SCHEMA (LENGKAP & FINAL)
-- Disesuaikan dengan Flutter project ReuseU (Juli 2026)
--
-- CARA PAKAI:
--   → Database baru (fresh): jalankan seluruh file ini
--   → Database sudah ada  : jalankan hanya bagian MIGRASI
--     di bagian paling bawah file ini
-- ============================================================


-- ============================================================
-- 1. TABEL PROFILES
--    Menyimpan data publik setiap user (extends auth.users)
-- ============================================================
create table public.profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  username    text unique,   -- NIM mahasiswa
  full_name   text,
  avatar_url  text,
  phone       text,          -- No. WhatsApp
  location    text,          -- format: "Universitas - Kota/Lokasi"
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);


-- ============================================================
-- 2. TABEL PRODUCTS
--    Menyimpan semua barang yang dijual
-- ============================================================
create table public.products (
  id          uuid primary key default gen_random_uuid(),
  seller_id   uuid not null references public.profiles(id) on delete cascade,
  name        text not null,
  description text,
  price       integer not null check (price >= 0),
  condition   text not null check (condition in ('Baru', 'Seperti Baru', 'Baik', 'Layak Pakai')),
  category    text not null,  -- Fashion, Alat Tulis, Elektronik, Furnitur, Dapur, Lainnya
  location    text,
  status      text not null default 'available' check (status in ('available', 'sold', 'reserved')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);


-- ============================================================
-- 3. TABEL PRODUCT_IMAGES
--    1 produk bisa punya banyak foto (maks 5)
-- ============================================================
create table public.product_images (
  id          uuid primary key default gen_random_uuid(),
  product_id  uuid not null references public.products(id) on delete cascade,
  image_url   text not null,   -- URL publik dari Supabase Storage
  order_index integer default 0 -- Urutan tampil foto
);


-- ============================================================
-- 4. TABEL WISHLISTS
--    Barang yang di-bookmark user
-- ============================================================
create table public.wishlists (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  product_id  uuid not null references public.products(id) on delete cascade,
  created_at  timestamptz default now(),
  unique(user_id, product_id) -- 1 user tidak bisa bookmark produk yang sama 2x
);


-- ============================================================
-- 5. TABEL CHATS
--    Room percakapan antara buyer & seller per produk
-- ============================================================
create table public.chats (
  id              uuid primary key default gen_random_uuid(),
  buyer_id        uuid not null references public.profiles(id) on delete cascade,
  seller_id       uuid not null references public.profiles(id) on delete cascade,
  product_id      uuid references public.products(id) on delete set null,
  last_message_at timestamptz default now(),
  unique(buyer_id, seller_id, product_id) -- 1 room per pasang user per produk
);


-- ============================================================
-- 6. TABEL MESSAGES
--    Isi pesan dalam setiap chat
-- ============================================================
create table public.messages (
  id          uuid primary key default gen_random_uuid(),
  chat_id     uuid not null references public.chats(id) on delete cascade,
  sender_id   uuid not null references public.profiles(id) on delete cascade,
  content     text not null,
  is_read     boolean default false,
  created_at  timestamptz default now()
);


-- ============================================================
-- 7. TABEL TRANSACTIONS
--    Riwayat transaksi jual-beli
-- ============================================================
create table public.transactions (
  id          uuid primary key default gen_random_uuid(),
  buyer_id    uuid not null references public.profiles(id),
  seller_id   uuid not null references public.profiles(id),
  product_id  uuid references public.products(id) on delete set null,
  price       integer not null,
  status      text not null default 'pending'
              check (status in ('pending', 'confirmed', 'completed', 'cancelled')),
  created_at  timestamptz default now(),
  updated_at  timestamptz default now()
);


-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Trigger 1: Otomatis simpan data profil saat user baru register
-- Menyalin full_name, username (NIM), phone, location dari metadata auth
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, avatar_url, username, phone, location)
  values (
    new.id,
    new.raw_user_meta_data->>'full_name',
    new.raw_user_meta_data->>'avatar_url',
    new.raw_user_meta_data->>'username',
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'location'
  )
  on conflict (id) do update
    set
      full_name = coalesce(excluded.full_name, public.profiles.full_name),
      username  = coalesce(excluded.username,  public.profiles.username),
      phone     = coalesce(excluded.phone,     public.profiles.phone),
      location  = coalesce(excluded.location,  public.profiles.location);
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- Trigger 2: Otomatis update last_message_at di tabel chats
-- saat pesan baru dikirim ke dalam chat tersebut
create or replace function public.update_chat_last_message()
returns trigger as $$
begin
  update public.chats set last_message_at = now() where id = new.chat_id;
  return new;
end;
$$ language plpgsql;

create trigger on_new_message
  after insert on public.messages
  for each row execute procedure public.update_chat_last_message();


-- Trigger 3: Otomatis update kolom updated_at saat data diubah
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger set_products_updated_at
  before update on public.products
  for each row execute procedure public.set_updated_at();

create trigger set_transactions_updated_at
  before update on public.transactions
  for each row execute procedure public.set_updated_at();

create trigger set_profiles_updated_at
  before update on public.profiles
  for each row execute procedure public.set_updated_at();


-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Keamanan akses data di level database berdasarkan user login
-- ============================================================

-- Aktifkan RLS di semua tabel
alter table public.profiles     enable row level security;
alter table public.products     enable row level security;
alter table public.product_images enable row level security;
alter table public.wishlists    enable row level security;
alter table public.chats        enable row level security;
alter table public.messages     enable row level security;
alter table public.transactions enable row level security;


-- PROFILES
create policy "Profiles are viewable by everyone"
  on public.profiles for select using (true);

create policy "Users can insert own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);


-- PRODUCTS
create policy "Products are viewable by everyone"
  on public.products for select using (true);

create policy "Users can insert their own products"
  on public.products for insert
  with check (auth.uid() = seller_id);

create policy "Users can update their own products"
  on public.products for update
  using (auth.uid() = seller_id);

create policy "Users can delete their own products"
  on public.products for delete
  using (auth.uid() = seller_id);


-- PRODUCT_IMAGES
create policy "Product images viewable by everyone"
  on public.product_images for select using (true);

create policy "Seller can manage product images"
  on public.product_images for all
  using (auth.uid() = (select seller_id from public.products where id = product_id));


-- WISHLISTS
create policy "Users can manage their wishlists"
  on public.wishlists for all using (auth.uid() = user_id);


-- CHATS
create policy "Chat participants can view their chats"
  on public.chats for select
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

create policy "Buyer can create chats"
  on public.chats for insert
  with check (auth.uid() = buyer_id);


-- MESSAGES
create policy "Chat participants can view messages"
  on public.messages for select
  using (
    auth.uid() in (
      select buyer_id  from public.chats where id = chat_id
      union
      select seller_id from public.chats where id = chat_id
    )
  );

create policy "Chat participants can send messages"
  on public.messages for insert
  with check (
    auth.uid() = sender_id and
    auth.uid() in (
      select buyer_id  from public.chats where id = chat_id
      union
      select seller_id from public.chats where id = chat_id
    )
  );


-- TRANSACTIONS
create policy "Users can view their transactions"
  on public.transactions for select
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

create policy "Buyer can create transactions"
  on public.transactions for insert
  with check (auth.uid() = buyer_id);


-- ============================================================
-- STORAGE BUCKETS
-- product-images : foto barang (publik)
-- avatars        : foto profil user (publik)
-- ============================================================

insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true);

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true);


-- Storage: product-images
create policy "Product images are public"
  on storage.objects for select
  using (bucket_id = 'product-images');

create policy "Users can upload product images"
  on storage.objects for insert
  with check (
    bucket_id = 'product-images' and
    auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can update their product images"
  on storage.objects for update
  using (
    bucket_id = 'product-images' and
    auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can delete their product images"
  on storage.objects for delete
  using (
    bucket_id = 'product-images' and
    auth.uid()::text = (storage.foldername(name))[1]
  );


-- Storage: avatars
create policy "Avatars are public"
  on storage.objects for select
  using (bucket_id = 'avatars');

create policy "Users can upload their avatar"
  on storage.objects for insert
  with check (
    bucket_id = 'avatars' and
    auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can update their avatar"
  on storage.objects for update
  using (
    bucket_id = 'avatars' and
    auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can delete their avatar"
  on storage.objects for delete
  using (
    bucket_id = 'avatars' and
    auth.uid()::text = (storage.foldername(name))[1]
  );


-- ============================================================
-- INDEX (mempercepat query yang sering dijalankan)
-- ============================================================

create index if not exists idx_products_status_created
  on public.products (status, created_at desc);

create index if not exists idx_products_seller_id
  on public.products (seller_id);

create index if not exists idx_wishlists_user_id
  on public.wishlists (user_id, created_at desc);

create index if not exists idx_chats_buyer_id
  on public.chats (buyer_id);

create index if not exists idx_chats_seller_id
  on public.chats (seller_id);

create index if not exists idx_messages_chat_id_created
  on public.messages (chat_id, created_at asc);

create index if not exists idx_transactions_buyer_id
  on public.transactions (buyer_id);

create index if not exists idx_transactions_seller_id
  on public.transactions (seller_id);

create index if not exists idx_product_images_product_id
  on public.product_images (product_id, order_index asc);


-- ============================================================
-- MIGRASI: PERBAIKI DATA USER LAMA
-- Jalankan bagian ini jika database sudah pernah dipakai
-- sebelum trigger handle_new_user diperbaiki.
-- Fungsi: menyalin username, phone, location dari auth.users
-- ke tabel profiles untuk semua user yang datanya masih NULL.
-- ============================================================

update public.profiles p
set
  full_name = coalesce(p.full_name, u.raw_user_meta_data->>'full_name'),
  username  = coalesce(p.username,  u.raw_user_meta_data->>'username'),
  phone     = coalesce(p.phone,     u.raw_user_meta_data->>'phone'),
  location  = coalesce(p.location,  u.raw_user_meta_data->>'location')
from auth.users u
where p.id = u.id
  and (
    p.username  is null or
    p.phone     is null or
    p.location  is null or
    p.full_name is null
  );


-- ============================================================
-- VERIFIKASI (opsional — jalankan terpisah untuk cek hasil)
-- ============================================================

-- Cek semua RLS policy yang aktif:
-- select schemaname, tablename, policyname, cmd
-- from pg_policies
-- where schemaname = 'public'
-- order by tablename, cmd;

-- Cek data profiles hasil migrasi:
-- select id, full_name, username, phone, location
-- from public.profiles
-- order by created_at desc
-- limit 20;
