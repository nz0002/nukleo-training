insert into public.categories(name,slug,sort_order) values
('Camisetas','camisetas',1),('Rashguards','rashguards',2),('Sudaderas','sudaderas',3),('Chándales','chandales',4)
on conflict (slug) do nothing;
-- La web trae un fallback local para desarrollo; la carga inicial del catálogo en Supabase se puede
-- hacer desde el panel tras configurar admin. No se insertan datos de productos duplicados aquí.
