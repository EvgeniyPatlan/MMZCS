**Лабораторна робота №6: Генерація та перевірка сертифікатів за допомогою OpenSSL**

**Мета:** Навчитися генерувати сертифікати за допомогою OpenSSL, включаючи сертифікат центру сертифікації (CA) та сертифікати користувачів, і перевіряти їх за допомогою Bash-скриптів.

**Теоретичні відомості**

Ця лабораторна робота присвячена використанню OpenSSL для генерації та перевірки сертифікатів. Сертифікати є важливою частиною безпечного зв'язку, використовуються для автентифікації сторін та встановлення довіри у криптографічних обмінах.

**Сертифікати та OpenSSL**  
- **CA-сертифікат**: Центр сертифікації (CA) видає цифрові сертифікати, виступаючи як довірена особа.  
- **Сертифікати користувачів**: Сертифікати для окремих осіб (Користувач A, Користувач B) підписуються центром сертифікації для підтвердження їхньої автентичності.

**Опис реалізації**

Лабораторна робота включає два Bash-скрипти (`generate_certs.sh` і `test_script.sh`), які виконують наступне:

1. **Генерація сертифікатів**:
   - Генерація сертифікатів CA та користувачів за допомогою `generate_certs.sh`.
   - Скрипт створює ключі для CA, Користувача A та Користувача B, і підписує їхні сертифікати за допомогою ключа CA.

2. **Тестування та перевірка**:
   - Запустіть `test_script.sh` для перевірки того, що всі сертифікати згенеровано правильно та вони дійсні.
   - Перевірте сертифікат CA, а також сертифікати Користувача A і Користувача B, щоб переконатися, що вони відповідають вимогам безпеки.

**Як працює програма**

1. **Генерація сертифікатів**:
   - Запустіть `./generate_certs.sh` для генерації сертифікатів CA та користувачів.
   - Скрипт спочатку перевіряє наявність OpenSSL, а потім генерує самопідписаний сертифікат CA.
   - Генеруються ключові пари для Користувача A і Користувача B, після чого їхні сертифікати підписуються CA.

2. **Перевірка сертифікатів**:
   - Виконайте `./test_script.sh` для перевірки сертифікатів.
   - Скрипт перевіряє, що кожен ключ і сертифікат згенеровано правильно, і перевіряє їхню автентичність за допомогою команд OpenSSL.

**Як зібрати та запустити програму**

1. **Генерація сертифікатів**:
   - Переконайтеся, що OpenSSL встановлено (`sudo apt-get install openssl`).
   - Запустіть `./generate_certs.sh` для генерації:
     - Ключа та сертифіката CA.
     - Ключових пар та сертифікатів для Користувача A і Користувача B.
     - Сертифікатів у форматі PKCS#12 для Користувача A і Користувача B.
   
2. **Запуск тестів**:
   - Запустіть `./test_script.sh` для перевірки згенерованих сертифікатів.
   - Скрипт перевіряє наявність сертифікатів CA, Користувача A та Користувача B, а також їхню дійсність.

**Запуск тестів**

1. **Тестування генерації сертифікатів**:
   - Запустіть `./generate_certs.sh` для генерації сертифікатів для CA та користувачів.
   - Перевірте наявність очікуваних файлів сертифікатів (`ca_cert.pem`, `userA_cert.p12`, `userB_cert.p12`).

2. **Тестування за допомогою `test_script.sh`**:
   - Виконайте `./test_script.sh` для перевірки:
     - Успішної генерації всіх необхідних сертифікатів.
     - Дійсності сертифікатів CA, Користувача A та Користувача B за допомогою команд OpenSSL.

**Результати тестування**

Тестування було проведено за допомогою `test_script.sh` для перевірки згенерованих сертифікатів. Усі необхідні сертифікати (CA, Користувач A, Користувач B) були успішно згенеровані та перевірені без помилок, що підтверджує їхню автентичність і правильність.

**Висновки**

Ця лабораторна робота надала практичний досвід роботи з OpenSSL для генерації та управління сертифікатами. Ми навчилися створювати сертифікат CA та використовувати його для підписання сертифікатів користувачів, а також перевіряти їх. Цей процес є важливим для безпечного зв'язку і демонструє, як встановити довірену інфраструктуру відкритих ключів (PKI) за допомогою інструментів OpenSSL та скриптів Bash.

