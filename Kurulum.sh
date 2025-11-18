#!/bin/bash
# MEB Sertifikası Kurulum Scripti - Çoklu Dağıtım + Doğrulama

CERT_FILE="MEB_SERTIFIKASI.cer"
CERT_URL="https://sertifika.meb.gov.tr/MEB_SERTIFIKASI.cer"
CRT_PATH="/usr/share/ca-certificates/meb/MEB_SERTIFIKASI.crt"

# -------------------------
# Dağıtım Tespiti
# -------------------------
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

DISTRO=$(detect_distro)

# -------------------------
# Paket yükleme
# -------------------------
install_packages() {
    case "$DISTRO" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y openssl ca-certificates wget
            ;;
        arch|manjaro)
            sudo pacman -Sy --noconfirm openssl ca-certificates wget
            ;;
        fedora|rhel)
            sudo dnf install -y openssl ca-certificates wget
            ;;
        opensuse*)
            sudo zypper install -y openssl ca-certificates wget
            ;;
        *)
            echo "Bu dağıtım desteklenmiyor: $DISTRO"
            exit 1
            ;;
    esac
}

install_packages

# -------------------------
# Sertifika dosyasını kontrol et / indir
# -------------------------
if [ ! -f "$CERT_FILE" ]; then
    echo "Sertifika dosyası bulunamadı. İndiriliyor..."
    wget -O "$CERT_FILE" "$CERT_URL"

    if [ ! -f "$CERT_FILE" ]; then
        echo "Sertifika indirilemedi! ($CERT_URL)"
        echo "Lütfen manuel indirip script ile aynı klasöre koyun."
        exit 1
    fi
fi

# -------------------------
# Sisteme kopyala ve dönüştür
# -------------------------
sudo mkdir -p /usr/share/ca-certificates/meb
sudo cp "$CERT_FILE" /usr/share/ca-certificates/meb/

sudo openssl x509 -inform DER \
    -in "/usr/share/ca-certificates/meb/$CERT_FILE" \
    -out "$CRT_PATH"

# -------------------------
# Sistem CA store güncelleme
# -------------------------
case "$DISTRO" in
    ubuntu|debian)
        sudo update-ca-certificates --fresh
        ;;
    arch|manjaro)
        sudo trust anchor "$CRT_PATH"
        ;;
    fedora|rhel)
        sudo update-ca-trust extract
        ;;
    opensuse*)
        sudo update-ca-certificates
        ;;
esac

# -------------------------
# DOĞRULAMA
# -------------------------

echo ""
echo "==> Sertifika doğrulaması yapılıyor..."

# 1. Dosya gerçekten oluşmuş mu?
if [ ! -f "$CRT_PATH" ]; then
    echo "HATA: CRT dosyası bulunamadı: $CRT_PATH"
    exit 1
fi

# 2. OpenSSL ile doğrulama
openssl x509 -in "$CRT_PATH" -noout -text >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "HATA: Sertifika bozuk veya okunamıyor!"
    exit 1
fi

# 3. Dağıtıma özel trust store kontrolü
case "$DISTRO" in
    ubuntu|debian)
        grep -q "MEB_SERTIFIKASI.crt" /etc/ca-certificates.conf
        if [ $? -ne 0 ]; then
            echo "HATA: Sertifika CA listesine eklenmemiş görünüyor!"
            exit 1
        fi
        ;;
    arch|manjaro)
        trust list | grep -q "MEB" >/dev/null
        if [ $? -ne 0 ]; then
            echo "HATA: Sertifika trust store'a eklenmemiş görünüyor!"
            exit 1
        fi
        ;;
    fedora|rhel)
        trust list | grep -q "MEB" >/dev/null
        if [ $? -ne 0 ]; then
            echo "HATA: Fedora trust store'da görünmüyor."
            exit 1
        fi
        ;;
    opensuse*)
        trust list | grep -q "MEB" >/dev/null
        if [ $? -ne 0 ]; then
            echo "HATA: openSUSE trust store'da görünmüyor."
            exit 1
        fi
        ;;
esac

echo "Sertifika başarıyla kuruldu ve doğrulandı. (Dağıtım: $DISTRO)"

