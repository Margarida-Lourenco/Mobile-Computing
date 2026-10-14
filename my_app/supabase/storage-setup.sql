-- Configure only the two image buckets. Keep all existing object access policies
-- under review: no anonymous/client upload/delete policy is needed by this function.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
 ('profile-images', 'profile-images', false, 5242880, array['image/jpeg','image/png','image/webp']),
 ('event-images', 'event-images', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update set public = false, file_size_limit = 5242880,
 allowed_mime_types = array['image/jpeg','image/png','image/webp'];
