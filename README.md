# MEB Sertifikası Kurulum Scripti

Bu script, Milli Eğitim Bakanlığı tarafından kullanılan **MEB_SERTIFIKASI.cer** kök sertifikasını Linux sisteminize otomatik olarak ekler.

Script aşağıdaki işlemleri yapar:

1. Sertifika dosyası klasörde yoksa **MEB üzerinden otomatik indirir**
2. .cer dosyasını sistem için uygun .crt formatına dönüştürür
3. Dağıtıma özel CA deposuna ekler
4. Doğrulama yaparak kurulumun doğru tamamlandığını kontrol eder

## Desteklenen Dağıtımlar

Script şu dağıtımlarda otomatik uyumlu çalışır:

* **Ubuntu / Debian**
* **Arch Linux / Manjaro**
* **Fedora / RHEL**
* **openSUSE**

---

## Kurulum

### 1. Script’i çalıştırma izni verin

```bash
chmod +x Kurulum.sh
```

### 2. Script’i çalıştırın

```bash
sudo ./Kurulum.sh
```

Script çalışırken:

* Sertifika dosyasını bulamazsa otomatik olarak **[https://sertifika.meb.gov.tr](https://sertifika.meb.gov.tr)** üzerinden indirir.
* Gerekli paketleri kurar (openssl, ca-certificates, wget).
* Sertifikayı `/usr/share/ca-certificates/meb/` içine ekler.
* Sistem CA deposunu günceller.
* Kurulum sonrası doğrulama yapar.

---

## Doğrulama

Script kurulum sonrası otomatik doğrulama yapar, ancak kendiniz manuel olarak doğrulamak isterseniz:

### Sertifikanın sistemde bulunması

```bash
trust list | grep -i meb
```

### Sertifikanın okunabilir olması

```bash
openssl x509 -in /usr/share/ca-certificates/meb/MEB_SERTIFIKASI.crt -noout -text
```

---

# Tarayıcılara Sertifika Manuel Nasıl Eklenir?

Bazı tarayıcılar (özellikle Firefox) kendi CA deposunu kullanır. Bu nedenle sistem sertifikası tarayıcıya otomatik eklenmeyebilir. Aşağıdaki adımlar tarayıcılara manuel ekleme içindir.

---

## Firefox İçin

Firefox sistem CA deposunu **otomatik kullanmaz**. Sertifikayı tarayıcıya elle eklemeniz gerekir.

### Adımlar:

1. Firefox’u açın
2. Adres çubuğuna yazın:

   ```
   about:preferences#privacy
   ```
3. Aşağıya inip **Sertifikalar → Sertifikaları Görüntüle** butonuna tıklayın
4. **Yetkililer (Authorities)** sekmesine geçin
5. **İçe Aktar** butonuna tıklayın
6. `MEB_SERTIFIKASI.crt` dosyasını seçin
   (Konum: `/usr/share/ca-certificates/meb/MEB_SERTIFIKASI.crt`)
7. Aşağıdaki kutuları işaretleyin:

   * Bu CA, web sitelerini tanımlayabilir.

---

## Google Chrome / Chromium / Edge

Bu tarayıcılar Linux'ta **sistem CA deposunu** kullanır.
Yani script çalıştıktan sonra ekstra işlem gerekmeyebilir.

Ancak manuel eklemek isterseniz:

### Adımlar:

1. Tarayıcıyı açın
2. Ayarlar → Gizlilik ve Güvenlik → Güvenlik → **Sertifika Yönetimi**
3. "Authority" veya "Yetkili" sekmesine gidin
4. **Import / İçe Aktar** butonuna basın
5. `MEB_SERTIFIKASI.crt` dosyasını seçin
6. Onaylayın

Chrome/Edge otomatik olarak sistem CA deposu ile senkronize olduğu için genelde gerekmez.

---

## Brave Tarayıcı

Brave de **Chrome ile aynı CA deposunu** kullanır.

Yani script'ten sonra normalde gerekmez.
Manuel eklemek isterseniz Chrome ile aynı adımlar geçerlidir.

---

# Sertifika Dosyası Konumu

Kurulum sonrası dosyalar:

```
/usr/share/ca-certificates/meb/MEB_SERTIFIKASI.cer
/usr/share/ca-certificates/meb/MEB_SERTIFIKASI.crt
```

---

## Notlar

* Script yalnızca kök sertifikayı sisteme güvenilir olarak ekler; içerik değiştirmez.
* MEB sertifikasının kaynağı:

  ```
  https://sertifika.meb.gov.tr/MEB_SERTIFIKASI.cer
  ```
