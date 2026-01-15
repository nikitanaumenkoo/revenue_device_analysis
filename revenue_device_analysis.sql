-- ===============================
-- Revenue and Account Metrics by Continent and Device
-- ===============================

-- Розрахунок виручки по континентах з розбивкою по пристроях
WITH revenue_usd AS (
    SELECT
        sp.continent,
        SUM(p.price) AS revenue,
        SUM(CASE WHEN device = 'mobile' THEN p.price END) AS revenue_from_mobile,
        SUM(CASE WHEN device = 'desktop' THEN p.price END) AS revenue_from_desktop
    FROM `DA.order` o
    JOIN `DA.product` p
        ON p.item_id = o.item_id
    JOIN `DA.session_params` sp
        ON o.ga_session_id = sp.ga_session_id
    GROUP BY sp.continent
),

-- Розрахунок кількості акаунтів та сесій по континентах
acnt_and_sessions AS (
    SELECT
        sp.continent,
        COUNT(a.id) AS Account_Count,
        COUNT(CASE WHEN is_verified = 1 THEN a.id END) AS Verified_Account,
        COUNT(sp.ga_session_id) AS Session_Count
    FROM `DA.session_params` sp
    LEFT JOIN `DA.account_session` acs
        ON sp.ga_session_id = acs.ga_session_id
    LEFT JOIN `DA.account` a
        ON acs.account_id = a.id
    GROUP BY sp.continent
)

-- Обʼєднання метрик по виручці та акаунтах
SELECT
    revenue_usd.continent,
    revenue_usd.revenue,
    revenue_usd.revenue_from_mobile,
    revenue_usd.revenue_from_desktop,
    (revenue_usd.revenue_from_mobile + revenue_usd.revenue_from_desktop) / revenue_usd.revenue AS percent_Revenue_from_Total,
    acnt_and_sessions.Account_Count,
    acnt_and_sessions.Verified_Account,
    acnt_and_sessions.Session_Count
FROM acnt_and_sessions
LEFT JOIN revenue_usd
    ON acnt_and_sessions.continent = revenue_usd.continent;
