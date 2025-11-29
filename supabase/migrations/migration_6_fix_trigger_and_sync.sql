-- حل نهائي: إصلاح الـ trigger ومزامنة البيانات

-- الخطوة 1: امسح الـ trigger والـ function القديمة
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- الخطوة 2: أنشئ الـ function من جديد بدون SECURITY DEFINER
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER -- يشتغل بصلاحيات أعلى
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  -- Insert into users table
  INSERT INTO public.users (id, email, user_type)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'user_type', 'donor')
  )
  ON CONFLICT (id) DO NOTHING; -- لو المستخدم موجود، متعملش حاجة
  
  RETURN NEW;
END;
$$;

-- الخطوة 3: أنشئ الـ trigger من جديد
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- الخطوة 4: زامن المستخدمين الموجودين
-- هيضيف كل المستخدمين اللي في auth.users لجدول public.users
INSERT INTO public.users (id, email, user_type)
SELECT 
  id,
  email,
  COALESCE(raw_user_meta_data->>'user_type', 'donor')
FROM auth.users
WHERE id NOT IN (SELECT id FROM public.users)
ON CONFLICT (id) DO NOTHING;

-- الخطوة 5: تحقق من النتيجة
SELECT 'Users in auth.users:' as info, COUNT(*) as count FROM auth.users
UNION ALL
SELECT 'Users in public.users:' as info, COUNT(*) as count FROM public.users;
