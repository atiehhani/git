
# این دستورات برای آماده‌سازی یک دایرکتوری محلی و اتصال آن به GitLab هستند.  
اگر فایل‌های پروژه شما داخل این مسیر باشند، از اینجا به بعد تمام دستورات Git روی همین پوشه اعمال می‌شوند.  

```bash
cd /root/lotus
```
ایجاد یک Repository محلی Git
بعد از اجرای این دستور، یک پوشه مخفی .git ساخته می‌شود.این پوشه تمام تاریخچه Commitها و تنظیمات Git را نگهداری می‌کند.
```bash
git init
```
ست کردن یوزر برای ثبت کردن commit ها   
 Set git user identity (IMPORTANT)   
 ```bash
sudo git config --global user.email "your-email@example.com"
sudo git config --global user.name "Your Name"
```

تعریف Remote Repository - به Git می‌گویید: مخزن اصلی من در GitLab این آدرس است. برای مشاهده: 
```bash
git remote -v
```
```bash
git remote add origin https://192.168.243.9/usa/OV_List.git
```
تنظیم نام نویسنده Commit - هر Commit با این نام ثبت می‌شود.
```bash
git config user.name "USA"
git config user.email "lotus@caspian.com"
```
برای مشاهده کانفیگ
```bash
git config --list
```

غیرفعال کردن بررسی SSL - Git دیگر اعتبار Certificate را بررسی نمی‌کند.- معمولاً برای GitLabهای داخلی که Self-Signed Certificate دارند استفاده می‌شود.

```bash
git config http.sslverify false
```
#اضافه کردن تمام فایل‌ها به Stage - Git تمام فایل‌های پوشه فعلی را برای Commit آماده می‌کند.برای مشاهده: git status
```bash
git add .
```
#ساخت اولین Commit - همه فایل‌های Stage شده در تاریخچه Git ذخیره می‌شوند.
```bash
git commit -m "Initial commit for lotus branch"
```
======================================================  
# Sel-signed Certificate for https in gitlab 
it's the self-signed certificate problem. Let's fix this so you can clone your repository.  
__Solution 3:__ Fix for Current Clone Only (Per Repository)  
Try cloning with SSL verification disabled just for this operation  
```bash
git -c http.sslVerify=false clone https://192.168.X.X/usa/OV_List.git
```
__Solution 2:__ Fix Only for Your GitLab Server (More Secure)  
Get the certificate from your GitLab server  
```bash
echo -n | openssl s_client -connect 192.168.X.X:443 -servername 192.168.X.X 2>/dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END-CERTIFICATE-/p' > /tmp/gitlab.crt
```
Configure Git to trust this certificate for your specific server  
```bash
git config --global http."https://192.168.X.X/".sslCAInfo /tmp/gitlab.crt
```
Now try cloning again  
```bash
git clone https://192.168.X.X/usa/OV_List.git
```

### Handle Self-Signed Certificate Errors (The Likely Problem)
```bash
git config --global http.sslVerify false
```
Tell Git to trust it:  
```bash
git config --global http."https://192.168.X.X/".sslCAInfo ~/gitlab.crt
```
Update the remote URL to use HTTPS. Run this command with your new URL:  
```bash
git remote set-url origin https://192.168.X.X/your-username/your-repo.git
git remote -v
```
```bash
 git status
 git remote -v
 git remote show origin
 # Show all branches (local and remote)
 git branch -a # برای اینکه ببینی توی کدوم برنچ هستی
 # Show remote branches only
 git branch -r
 git config 
 git config --list
 git config --get init.defaultBranch
 git config --get remote.origin.url
 git branch
 git push -u origin master --force
```
 ===================  
## Create and switch to lotus branch
git branch -M lotus     /     git checkout -b lotus /# Check current branch    /git checkout lotus # Switch to lotus
                                    
git push -u origin lotus --force
