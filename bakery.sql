/*Топ 5 пекарей сделавших больше всего заказов*/

SELECT
    u.first_name,
    u.last_name,
    u.phone,
    COUNT(o.id)
FROM bakers b
JOIN users u
    ON b.user_id = u.id
JOIN orders o
    ON o.baker_id = b.id
WHERE
    o.finished IS TRUE
GROUP BY 1,2,3
ORDER BY 4 DESC
LIMIT 5


/*Информация о заказах, где клиент недоволен*/

SELECT
    delivery_date::date AS "дата",
    u.phone AS "телефон",
    u.first_name AS "имя",
    u.middle_name AS "отчество",
    amount_cents/100 AS "сумма заказа",
    raiting AS "оценка",
    comment AS "комментарий"
FROM orders o
JOIN users u
    ON o.user_id = u.id
WHERE
    o.raiting < 5


-- Количество пекарей каждого разряда

SELECT
    CASE
        WHEN type = 'baker' THEN 'пекарь'
        WHEN type = 'junior_baker' THEN 'младший пекарь'
        WHEN type = 'senior_baker' THEN 'старший пекарь'
    END AS "разряд",
    COUNT(*) AS "количество"
FROM bakers
GROUP BY 1


/*Хорошо ли пекари выполняют заказы или степень удовлетворенности клиентов пекарней*/

SELECT
    delivery_date::date AS "дата_доставки",
    ROUND(AVG(raiting), 2) AS "средний_рейтинг"
FROM orders
WHERE 
    finished IS TRUE
GROUP BY 1
ORDER BY 1

--------------
SELECT
    raiting,
    COUNT(id)
FROM orders
WHERE
    finished IS TRUE
GROUP BY 1
ORDER BY 1


/*Частота комментариев к заказам*/

SELECT
    COUNT(comment) * 100 /
    COUNT(id) AS "% заказов с комментариями"
FROM orders


/*Через какой канал и сколько поступило заказов*/

SELECT
    CASE
        WHEN creation_mean = 'web' THEN 'сайт'
        WHEN creation_mean = 'sales' THEN 'колл-центр'
        WHEN creation_mean = 'app' THEN 'приложение'
    END AS "источник",
COUNT(*) AS "количество"
FROM orders
GROUP BY 1
ORDER BY 2 DESC


/*Тестируем фичу от gmail на поварах*/

SELECT
    email
FROM users
WHERE
    type = 'baker' AND lower(email) LIKE '%@gmail.com%'


/*Как прошли заказы с комментариями на срочность*/

SELECT
    comment AS "комментарий",
    (delivery_date - created_at) AS "время изготовления заказа",
    raiting AS "рейтинг"
FROM orders
WHERE
    finished IS TRUE
    AND lower(comment) LIKE '%срочн%'
    OR lower(comment) LIKE '%быстр%'


/*Самый доходный канал*/

SELECT
    CASE
        WHEN creation_mean = 'web' THEN 'сайт'
        WHEN creation_mean = 'sales' THEN 'колл-центр'
        WHEN creation_mean = 'app' THEN 'приложение'
    END AS "канал привлечения"
FROM orders
WHERE
    finished IS true
GROUP BY 1
ORDER BY ROUND(SUM(amount_cents/100 * 0.5)) DESC
LIMIT 1


/*Отмененные заказы по месяцам*/

SELECT
    date_trunc('month', created_at)::date,
    COUNT(*)
FROM orders
WHERE
    cancelled_at IS NOT NULL
GROUP BY 1

------
SELECT
    extract(hour FROM created_at),
    COUNT(*)
FROM users
GROUP BY 1
ORDER BY 1


/*Какой процент от общей суммы заказов за месяц составил заказ того или иного покупателя*/

SELECT
       date_trunc('month', o.created_at)::date AS month,
       CONCAT(u.first_name, ' ', u.last_name) AS fio,
       o.id AS order_id,
       ROUND((amount_cents/100) * 100 / SUM(amount_cents/100)
       OVER(PARTITION BY baker_id, date_trunc('month', o.created_at)::date) :: numeric, 2)
       AS "процент от суммы за месяц"
FROM orders o
JOIN
    bakers b 
    ON o.baker_id = b.id
JOIN
    users u 
    ON b.user_id = u.id
WHERE
      finished IS TRUE
ORDER BY 1,2


/*Кто из пекарей выполнил заказов на большую сумму*/

WITH
    best_baker AS (
        SELECT 
            baker_id, 
            SUM(amount_cents/100)
        FROM orders
        WHERE 
            finished IS TRUE
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1
    )
SELECT o.*
FROM best_baker b
JOIN orders o 
    ON b.baker_id = o.baker_id
ORDER BY created_at DESC
LIMIT 1


/*Какой пекарь лучше всего выполняет заказы*/
 
 WITH
    best_baker AS (
        SELECT 
            baker_id, 
            AVG(raiting)
        FROM orders 
        WHERE 
            raiting IS NOT NULL
        GROUP BY 1
        ORDER BY 2 DESC
        LIMIT 1

    )
SELECT o.*
FROM best_baker b
JOIN orders o 
    ON o.baker_id = b.baker_id


