# 🎯 Supabase Migrations - ملخص سريع

## 📁 الملفات

### 1. `migration_1_create_tables.sql`
**الهدف:** إنشاء كل الجداول الأساسية

**الجداول:**
- ✅ users - المستخدمين
- ✅ donors - المتبرعين
- ✅ hospitals - المستشفيات
- ✅ blood_requests - طلبات التبرع
- ✅ notifications - الإشعارات

**المميزات:**
- Indexes للأداء
- Constraints للبيانات الصحيحة
- Triggers للـ updated_at تلقائياً
- Comments شاملة

---

### 2. `migration_2_enable_rls.sql`
**الهدف:** تفعيل Row Level Security

**السياسات:**
- Users: قراءة/تحديث البيانات الخاصة فقط
- Donors: الجميع يقرأ، المتبرع يحدّث بياناته
- Hospitals: الجميع يقرأ، المستشفى يحدّث بياناته
- Blood Requests: 
  - الجميع يقرأ
  - المستشفى فقط ينشئ ويحدّث طلباتها
  - المتبرع يحدّث الطلبات اللي قبلها
- Notifications: المستخدم يقرأ ويحدّث إشعاراته فقط

---

### 3. `migration_3_create_functions.sql`
**الهدف:** إنشاء Functions و Triggers التلقائية

**Functions:**

1. **handle_new_user()**
   - يعمل تلقائياً عند تسجيل مستخدم جديد
   - ينشئ سجل في جدول users

2. **notify_matching_donors()**
   - يعمل عند إنشاء طلب تبرع جديد
   - يبحث عن متبرعين مطابقين (فصيلة + موقع)
   - ينشئ إشعار In-App
   - يستدعي Edge Function لإرسال Push Notification

3. **notify_hospital_on_acceptance()**
   - يعمل عند قبول متبرع للطلب
   - يرسل إشعار للمستشفى

4. **get_matching_donors()**
   - Function للبحث عن متبرعين متاحين
   - يمكن استدعاؤها من Flutter

5. **get_donor_stats()** & **get_hospital_stats()**
   - إحصائيات المستخدم

---

### 4. `migration_4_enable_http_extension.sql`
**الهدف:** تفعيل pg_net للاتصال بـ Edge Functions

**الاستخدام:**
- يسمح للـ Triggers باستدعاء Edge Functions
- ضروري لإرسال الإشعارات

---

### 5. `migration_5_fix_user_insert_policy.sql`
**الهدف:** إصلاح RLS Policy لجدول users

**المشكلة:**
- الـ trigger `handle_new_user` كان مش قادر يعمل INSERT
- RLS Policy كانت بترفض الـ INSERT من الـ trigger

**الحل:**
- إضافة policy جديدة تسمح للـ authenticated role بالـ INSERT
- إضافة policy للـ service_role
- Grant permissions صحيحة

---

## 🚀 ترتيب التطبيق

**يجب تطبيقهم بالترتيب:**

1. ✅ migration_1_create_tables.sql
2. ✅ migration_2_enable_rls.sql
3. ✅ migration_3_create_functions.sql
4. ✅ migration_4_enable_http_extension.sql
5. ✅ migration_5_fix_user_insert_policy.sql ← **مهم جداً!**

---

## 🔄 كيفية التطبيق

### الطريقة 1: من Dashboard (الأسهل)

```
1. Supabase Dashboard > SQL Editor
2. New Query
3. انسخ محتوى Migration 1
4. الصق واضغط Run
5. كرر للـ Migrations الباقية
```

### الطريقة 2: Supabase CLI

```powershell
cd "c:\Users\mahmo\Downloads\Telegram Desktop\GIZ3_SWD8_G1_GA-main"
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

---

## ✅ التحقق

بعد التطبيق:

1. **Table Editor** يجب أن يعرض 5 جداول
2. **Database** > **Functions** يجب أن يعرض 5 functions
3. **Database** > **Triggers** يجب أن يعرض 3 triggers
4. **Database** > **Extensions** يجب أن يحتوي على pg_net

---

## 🐛 حل المشاكل

### Migration فشلت؟

```sql
-- امسح كل شيء وابدأ من جديد
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS blood_requests CASCADE;
DROP TABLE IF EXISTS hospitals CASCADE;
DROP TABLE IF EXISTS donors CASCADE;
DROP TABLE IF EXISTS users CASCADE;

DROP FUNCTION IF EXISTS handle_new_user CASCADE;
DROP FUNCTION IF EXISTS notify_matching_donors CASCADE;
DROP FUNCTION IF EXISTS notify_hospital_on_acceptance CASCADE;

-- ثم أعد تطبيق Migrations بالترتيب
```

### Trigger لا يعمل؟

```sql
-- تحقق من Triggers
SELECT * FROM pg_trigger;

-- أعد إنشاء Trigger
-- (أعد تشغيل Migration 3)
```

---

## 📖 لمزيد من التفاصيل

راجع: **SUPABASE_SETUP.md** - الدليل الشامل
