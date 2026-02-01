# I'KNOW - Yapay Zeka Asistanı

I'KNOW, Google Gemini API kullanarak geliştirilmiş modern ve hızlı bir yapay zeka asistanıdır. Sinatra (Ruby) framework'ü üzerine inşa edilmiştir ve kullanıcı dostu, premium bir deneyim sunar.

## Temel Özellikler

-   **Çoklu Model Desteği:** Gemini 3 Flash, Gemini 1.5 Flash ve deneysel modeller arasında kolay geçiş.
-   **Premium Tasarım:** Glassmorphism temalı sidebar, sticky (sabit) navbar ve Inter font ile modern görünüm.
-   **Akıllı Geçmiş Yönetimi:** Sohbetlerinizi oturum bazlı saklayan ve geçmişe dönük erişim sağlayan sistem.
-   **Hızlı ve Verimli:** Sinatra'nın hafif yapısı sayesinde düşük kaynak kullanımı ve yüksek hız.

## Proje Gelişim Süreci

Bu projenin sıfırdan bugünkü haline gelme sürecini, alınan teknik kararları ve tamamlanan aşamaları aşağıdaki dokümanlardan inceleyebilirsiniz:

-   **[Uygulama Planı](docs/history/implementation_plan.md):** Projenin teknik mimarisi ve planlama aşaması.
-   **[Geliştirme Özeti (Walkthrough)](docs/history/walkthrough.md):** Yapılan değişikliklerin, eklenen özelliklerin ve test sonuçlarının özeti.
-   **[Görev Listesi (Task List)](docs/history/task.md):** Geliştirme süreci boyunca takip edilen ve tamamlanan adımlar.

## Kurulum ve Çalıştırma

1.  Bağımlılıkları yükleyin:
    ```bash
    bundle install
    ```

2.  `.env` dosyasını oluşturun:
    ```env
    GEMINI_TOKEN=api_anahtariniz
    SESSION_SECRET=guvenli_bir_anahtar
    ```

3.  Uygulamayı başlatın:
    ```bash
    ruby app.rb
    ```

---
Geliştiren: [garalo](https://github.com/garalo)
