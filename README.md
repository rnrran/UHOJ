# Unhas Online Judge - Installation Guide

> **Repository Links:**
> - Frontend: [UHOJ-FE](https://github.com/rnrran/UHOJ-FE/)
> - Backend: [UHOJ-BE](https://github.com/rnrran/UHOJ-BE)
> - Deploy: [UHOJ](https://github.com/rnrran/UHOJ)

> **Note:** Repository ini menggunakan Git Submodules. Folder `backend-src/` dan `frontend-src/` adalah submodules yang link ke repository terpisah. Untuk clone dengan submodules: `git clone --recursive https://github.com/rnrran/UHOJ.git`


## Prerequisites

### System Requirements

- **Operating System:** Linux (Ubuntu 18.04 LTS or newer recommended)
- **Docker:** Version 20.10 or newer
- **Docker Compose:** Version 1.29 or newer
- **Disk Space:** At least 10GB free space
- **RAM:** Minimum 2GB (4GB recommended)
- **CPU:** 2 cores minimum

### Install Docker and Docker Compose

#### For Ubuntu/Debian:

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y vim python3-pip curl git

# Install Docker
sudo curl -sSL get.docker.com | sh

# Add your user to docker group (optional, to run docker without sudo)
sudo usermod -aG docker $USER
# Log out and log back in for group changes to take effect

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

#### For other Linux distributions:

Follow the official Docker installation guide: [https://docs.docker.com/install/](https://docs.docker.com/install/)

## Installation Steps

### 1. Clone or Navigate to Project Directory

**⚠️ IMPORTANT:** Repository ini menggunakan Git Submodules. Folder `backend-src/` dan `frontend-src/` adalah submodules yang link ke repository terpisah.

```bash
# Clone repository dengan submodules (PENTING!)
git clone --recursive https://github.com/rnrran/UHOJ.git
cd UHOJ

# Atau jika sudah clone tanpa submodules, update submodules:
git submodule update --init --recursive

# Atau jika you already have the project
cd OnlineJudgeDeploy
```

**Note:** Jika folder `backend-src/` dan `frontend-src/` kosong setelah clone, jalankan `git submodule update --init --recursive`.

### 2. Build the Application

Build all Docker images. This process will:
- Build frontend (Vue.js) from `frontend-src/`
- Build backend (Django) from `backend-src/`
- Install all dependencies
- Bundle frontend static files into backend image

```bash
# Build all services (takes 5-30 minutes depending on internet speed)
docker-compose build

# Or build specific service
docker-compose build oj-backend
```

**Note:** First build will take longer as it downloads base images and dependencies. Subsequent builds will be faster due to Docker layer caching.

### 3. Start the Services

```bash
# Start all services in detached mode (background)
docker-compose up -d

# View logs to monitor startup progress
docker-compose logs -f
```

**Services that will start:**
- `oj-redis` - Redis cache/queue service
- `oj-postgres` - PostgreSQL database
- `oj-judge` - Judge server for code execution
- `oj-backend` - Backend API + Frontend (main service)

### 4. Verify Installation

Wait for all services to be healthy (usually 1-2 minutes after startup):

```bash
# Check container status
docker-compose ps

# Expected output: All containers should show "Up" status
# No containers should show "unhealthy" or "Exited (x) xxx"
```

### 5. Access the Application

Once all containers are running:

- **Frontend:** http://localhost (or http://your-server-ip)
- **Admin Panel:** http://localhost/admin (or http://your-server-ip/admin)
- **HTTPS:** https://localhost (port 443)

## First Time Setup

### Login as Super Administrator

The system **automatically creates a super administrator account** during the first container startup:

- **Username:** `root`
- **Password:** `rootroot`
- **Role:** Super Admin (highest hierarchy with full system access)

**How it works:**
- The user is created automatically in `backend-src/deploy/entrypoint.sh`
- Command: `python manage.py inituser --username=root --password=rootroot --action=create_super_admin`
- This runs every time the container starts (if user doesn't exist)

**⚠️ IMPORTANT SECURITY NOTE:** 
- **Change the password immediately** after first login
- Go to `/admin` → User Management → Edit user `root` → Change password

### Initial Configuration

1. Login to admin panel at `/admin` using credentials above
2. Navigate to **System Configuration**
3. Configure:
   - Website name and settings
   - SMTP settings (for email notifications)
   - Judge server token (if using external judge servers)
   - Other system preferences

## Default Configuration

### Super Administrator Account

During the Docker build and startup process, the system **automatically creates a super administrator user** with the following credentials:

- **Username:** `root`
- **Password:** `rootroot`
- **Role:** Super Admin (highest hierarchy level with full system access)
- **Permissions:** Full access to all system features and settings

**How it works:**
- The user is created automatically in `backend-src/deploy/entrypoint.sh`
- Command: `python manage.py inituser --username=root --password=rootroot --action=create_super_admin`
- This runs every time the container starts (if user doesn't exist)

**⚠️ IMPORTANT:** Please change the password immediately after first login for security purposes.

### User Registration

**User registration is disabled by default** for security reasons. Only the super administrator can create new user accounts through the admin panel.

**To enable user registration** (not recommended for production):
1. Login as super admin at `/admin`
2. Navigate to **System Configuration**
3. Enable "Allow Register" option
4. Save changes

**To create users manually:**
1. Login as super admin
2. Go to `/admin` → **User Management**
3. Click **Add User** or **Import Users**
4. Fill in user details and assign appropriate roles

## Common Operations

### Stop Services

```bash
# Stop all services
docker-compose stop

# Stop specific service
docker-compose stop oj-backend
```

### Start Services

```bash
# Start all services
docker-compose start

# Start specific service
docker-compose start oj-backend
```

### Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart oj-backend
```

### View Logs

```bash
# View all logs
docker-compose logs

# View logs for specific service
docker-compose logs oj-backend

# Follow logs in real-time
docker-compose logs -f oj-backend

# View last 100 lines
docker-compose logs --tail=100 oj-backend
```

### Rebuild After Code Changes

```bash
# Rebuild and restart
docker-compose up -d --build

# Rebuild specific service
docker-compose build oj-backend
docker-compose up -d oj-backend
```

### Access Container Shell

```bash
# Enter backend container
docker-compose exec oj-backend sh

# Run Django management commands
docker-compose exec oj-backend python manage.py migrate
docker-compose exec oj-backend python manage.py createsuperuser
```

### Backup Database

```bash
# Backup PostgreSQL database
docker-compose exec oj-postgres pg_dumpall -U onlinejudge > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Clean Up

```bash
# Stop and remove containers (keeps volumes)
docker-compose down

# Stop, remove containers and volumes (⚠️ deletes all data)
docker-compose down -v

# Remove unused images
docker image prune -a
```

## Troubleshooting

### Containers Not Starting

```bash
# Check container status
docker-compose ps

# Check logs for errors
docker-compose logs oj-backend

# Check if ports are already in use
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker-compose ps oj-postgres

# Check PostgreSQL logs
docker-compose logs oj-postgres

# Restart database
docker-compose restart oj-postgres
```

### Frontend Not Loading

```bash
# Rebuild frontend
docker-compose build oj-backend

# Check if frontend files exist in container
docker-compose exec oj-backend ls -la /app/dist
```

### Permission Issues

```bash
# Fix data directory permissions
sudo chown -R $USER:$USER ./data

# Or set proper permissions
chmod -R 755 ./data
```

## Project Structure

```
OnlineJudgeDeploy/
├── docker-compose.yml          # Main Docker Compose configuration
├── backend-src/                # Backend source code (Django)
│   ├── Dockerfile              # Backend Dockerfile (multi-stage build)
│   └── deploy/                 # Deployment scripts
├── frontend-src/               # Frontend source code (Vue.js)
│   ├── Dockerfile              # Frontend Dockerfile (standalone, not used)
│   └── src/                    # Vue.js source files
├── data/                       # Persistent data (volumes)
│   ├── backend/                # Backend data
│   ├── postgres/               # Database data
│   └── redis/                  # Redis data
├── docs/                       # Documentation
│   ├── docker-tutorial/        # Docker tutorial for beginners
│   ├── problems/               # Problem templates
│   └── ...                     # Other documentation
└── logo.png                    # Logo Unhas (used as favicon)
```

**Note:** Frontend di-build dalam `backend-src/Dockerfile` menggunakan multi-stage build. Frontend standalone Dockerfile (`frontend-src/Dockerfile`) tidak digunakan dalam deployment ini.

## Test Case Format

When creating problems, test cases must be uploaded as a **ZIP file** with specific naming conventions.

### Format Requirements

**For Non-SPJ Problems (Standard Judge):**
- ZIP file must contain pairs of files: `1.in`, `1.out`, `2.in`, `2.out`, `3.in`, `3.out`, ...
- Files must start from `1` (not `0` or `2`)
- Each test case must have both input (`.in`) and output (`.out`) files

**For SPJ Problems (Special Judge):**
- ZIP file must contain only input files: `1.in`, `2.in`, `3.in`, ...
- Files must start from `1`
- No output files needed (SPJ code will judge the output)

### Example Structure

```
test_case.zip
├── 1.in      (Input for test case 1)
├── 1.out     (Expected output for test case 1)
├── 2.in      (Input for test case 2)
└── 2.out     (Expected output for test case 2)
```

### Common Errors

- **"Invalid ZIP file"**: You uploaded a non-ZIP file (e.g., `.txt`). Compress your test case files into a ZIP file.
- **"Empty file"**: ZIP doesn't contain files in correct format. Make sure files start from `1.in` and `1.out`, and are in the root of ZIP (not in subfolder).

**For detailed guide, see:** [docs/TEST_CASE_FORMAT.md](docs/TEST_CASE_FORMAT.md)

## Database Persistence

**✅ Database TERSIMPAN secara permanen!**

Data database (users, problems, submissions, contests) disimpan di folder `data/postgres/` di host. Ketika Anda melakukan `docker-compose down` dan `docker-compose up` lagi, **data tidak akan hilang**.

**Lokasi penyimpanan:**
- **PostgreSQL:** `./data/postgres/` (semua data database)
- **Redis:** `./data/redis/` (cache data)
- **Backend:** `./data/backend/` (test cases, uploads)

**⚠️ PENTING:** Jangan hapus folder `data/` jika ingin mempertahankan data!

Untuk detail lengkap, lihat: [docs/DATABASE_PERSISTENCE.md](docs/DATABASE_PERSISTENCE.md)

## Export Nilai untuk Ujian

**✅ Bisa mengekspor nilai dengan mudah!**

QDUOJ memiliki fitur export yang sangat cocok untuk ujian praktek pemrograman:

1. **Export Ranking (Excel/XLSX)** - Ranking lengkap dengan nilai per problem
2. **Download Submissions (ZIP)** - Semua kode submission yang accepted

**Cara menggunakan:**
- **Ranking Excel:** Buka contest rank → Klik "Download CSV" atau tambahkan `?download_csv=1` di URL
- **Submissions ZIP:** Admin → Contest List → "Download Accepted Submissions"

**Format export:**
- Excel berisi: User ID, Username, Real Name, AC/Score, Status per problem
- ZIP berisi: Kode submission per user dan problem

Untuk detail lengkap dan workflow ujian, lihat: [docs/EXPORT_GRADES.md](docs/EXPORT_GRADES.md)

## Migrasi ke Mesin Lain

**✅ Bisa dipindahkan dengan mudah!**

Data aplikasi disimpan di folder `data/` di host, sehingga bisa di-backup dan dipindahkan ke mesin lain.

**Cara migrasi:**
1. **Backup:** `tar -czf backup.tar.gz data/ docker-compose.yml`
2. **Transfer** ke mesin baru (scp, USB, cloud, dll)
3. **Extract:** `tar -xzf backup.tar.gz`
4. **Start:** `docker-compose up -d --build`

**Data akan tetap sama setelah migrasi!**

Untuk panduan lengkap, lihat: [docs/MIGRATION_GUIDE.md](docs/MIGRATION_GUIDE.md)

## Repository Links

### Unhas Online Judge (UHOJ) Repositories

- **Frontend (UHOJ-FE):** [https://github.com/rnrran/UHOJ-FE/](https://github.com/rnrran/UHOJ-FE/)
- **Backend (UHOJ-BE):** [https://github.com/rnrran/UHOJ-BE](https://github.com/rnrran/UHOJ-BE)
- **Deploy (UHOJ):** [https://github.com/rnrran/UHOJ](https://github.com/rnrran/UHOJ)

## Git Submodules

Repository ini menggunakan **Git Submodules** untuk menghubungkan `backend-src/` dan `frontend-src/` ke repository terpisah:

- `backend-src/` → [UHOJ-BE](https://github.com/rnrran/UHOJ-BE)
- `frontend-src/` → [UHOJ-FE](https://github.com/rnrran/UHOJ-FE)

Di GitHub, folder tersebut akan menampilkan sebagai link ke repository aslinya (bukan `blob/...`).

**Setup Submodules (untuk maintainer):**
```bash
# Hapus folder yang sudah ada dari git (jika sudah di-commit)
git rm -r --cached backend-src frontend-src

# Tambahkan sebagai submodules
git submodule add https://github.com/rnrran/UHOJ-BE.git backend-src
git submodule add https://github.com/rnrran/UHOJ-FE.git frontend-src

# Commit perubahan
git commit -m "Convert backend-src and frontend-src to submodules"
git push
```

**Update Submodules (untuk user):**
```bash
# Clone dengan submodules
git clone --recursive https://github.com/rnrran/UHOJ.git

# Atau update submodules jika sudah clone
git submodule update --init --recursive

# Update ke latest version
git submodule update --remote
```

**Lihat dokumentasi lengkap:** [docs/GIT_SUBMODULES.md](docs/GIT_SUBMODULES.md)

## Nginx Virtual Hosting Setup

Jika server Anda sudah memiliki nginx berjalan di port 80, Anda bisa setup OnlineJudge menggunakan virtual hosting dengan reverse proxy.

**Langkah-langkah:**
1. Ubah port mapping di `docker-compose.yml` ke `127.0.0.1:8080:8000`
2. Setup nginx virtual host dengan reverse proxy ke `127.0.0.1:8080`
3. Enable virtual host dan reload nginx

**Lihat dokumentasi lengkap:** [docs/NGINX_VIRTUAL_HOST.md](docs/NGINX_VIRTUAL_HOST.md)

**File contoh:** `docker-compose.nginx-proxy.yml.example`

## Additional Resources

- **Original Documentation:** http://opensource.qduoj.com/
- **Docker Tutorial:** See `docs/docker-tutorial/` for comprehensive Docker guide
- **Test Case Format Guide:** See `docs/TEST_CASE_FORMAT.md` for detailed test case format
- **Database Persistence:** See `docs/DATABASE_PERSISTENCE.md` for database storage details
- **Export Grades:** See `docs/EXPORT_GRADES.md` for exporting grades and submissions
- **Migration Guide:** See `docs/MIGRATION_GUIDE.md` for migrating to another machine
- **Git Submodules Guide:** See `docs/GIT_SUBMODULES.md` for Git Submodules setup and usage
- **Nginx Virtual Hosting:** See `docs/NGINX_VIRTUAL_HOST.md` for setting up with existing nginx
- **GitHub Issues:** Report issues in the project repository

## License

This project is based on [QingdaoU/OnlineJudge](https://github.com/QingdaoU/OnlineJudge) which is licensed under MIT License.
