#!/bin/bash

# 1.    Подготавливаем epc_widget_list_pairs
# 1.1.  Загружаем JSON для встраивания из $PATH_JSON                                                        -> epc_widget_json
# 1.2.  Значение "productOfferCfg" - замена с null на []                                                    -> epc_widget_json
# 1.3.  Минифицируем epc_widget_json                                                                        -> epc_widget_minified
# 1.4.  Убираем внешние фигурные скобки у json_response_minified                                            -> epc_widget_list_pairs
# 2.    Подготовка rt_widget_config_pretty
# 2.1.  Минифицируем RT_WIDGET_CONFIG                                                                       -> rt_widget_config_minified
# 2.2.  Замена <"placeholder_json_response": "value"> на epc_widget_list_pairs в rt_widget_config_minified  -> rt_widget_config_minified
# 2.3.  Преобразуем rt_widget_config_minified в удобочитаемый вид                                           -> rt_widget_config_beauty
# 3.    Создание файла встройки
# 3.1.  В переменной TEMPLATE меняем текст rt_widget_config_beauty на переменную rt_widget_config_beauty    -> vk_result
# 3.2.  Создание файла PATH_RESULT с содержимым vk_result

export LC_ALL=ru_RU.UTF-8
export LANG=ru_RU.UTF-8

# Объявление констант
PATH_JSON="/home/ruslan/Documents/RTK_IT/VK_productOffer.json"
PATH_TEMPLATE="/home/ruslan/Documents/RTK_IT/VK_template.html"
PATH_RESULT="/home/ruslan/Documents/RTK_IT/VK_result.html"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение PATH_JSON: $PATH_JSON"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение PATH_TEMPLATE: $PATH_TEMPLATE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение PATH_RESULT: $PATH_RESULT"

TEMPLATE='<!DOCTYPE html>
<html lang="ru">

<head>
    <meta http-equiv="X-UA-Compatible" content="IE=11">
    <meta name="google" content="notranslate">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
</head>

<body>
    <div id="epc-widget"></div>
    <script>window.RT_WIDGET_CONFIG = rt_widget_config_beauty</script>
    <script src="https://epc-api.rt.ru/apiman-gateway/epc-front-wc/epc-offers-widget/1.8.4/static/js/app.js"></script>
</body>

</html>'

RT_WIDGET_CONFIG='{
    "epc-widget": {
        "apiKey": "0106e80d-ae53-48e3-a12a-a1002896a7fb",
        "placeholder_json_response": "value",
        "contactInfo": {
            "phoneNumber": "9139139139",
            "email": ""
        },
        "differencePOC": false,
        "outputData": {
            "status": true,
            "onChangePrice": "function(){}"
        },
        "_buildDate": "21.11.2024"
    }
}'


echo ""
echo "1.1.  Загружаем JSON для встраивания из $PATH_JSON:"
epc_widget_json=$(cat "$PATH_JSON")

echo ""
echo "1.2.  Значение "productOfferCfg" - замена с null на []:"
# product_offer_cfg=$(echo "$epc_widget_json" | jq -r '.data.productOfferCfg')
product_offer_cfg=$(echo "$epc_widget_json" | jq -r '.productOfferCfg')
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение product_offer_cfg: $product_offer_cfg"
# Обновляем исходный JSON с измененным productOfferCfg
modified_product_offer_cfg='[]'
epc_widget_json=$(echo "$epc_widget_json" | jq --argjson new "$modified_product_offer_cfg" '.productOfferCfg = $new')
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение epc_widget_json: $epc_widget_json"

echo ""
echo "1.3.  Минифицируем epc_widget_json:"
epc_widget_minified=$(echo "$epc_widget_json" | jq -c .)

echo ""
echo "1.4.  Убираем внешние фигурные скобки у json_response_minified:"
epc_widget_list_pairs="${epc_widget_minified:1:-1}"

echo ""
echo "2.1.  Минифицируем RT_WIDGET_CONFIG:"
rt_widget_config_minified=$(echo "$RT_WIDGET_CONFIG" | jq -c .)

echo ""
echo "2.2.  Замена <"placeholder_json_response": "value"> на epc_widget_list_pairs в rt_widget_config_minified:"
rt_widget_config_minified="${rt_widget_config_minified//\"placeholder_json_response\":\"value\"/$epc_widget_list_pairs}"

echo ""
echo "2.3.  Преобразуем rt_widget_config_minified в удобочитаемый вид:"
rt_widget_config_beauty=$(echo "$rt_widget_config_minified" | jq '.')
# echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config_beauty: $rt_widget_config_beauty"

echo ""
echo "3.1.  В переменной TEMPLATE меняем <rt_widget_config_beauty> на переменную rt_widget_config_beauty:"
vk_result="${TEMPLATE//rt_widget_config_beauty/$rt_widget_config_beauty}"
# echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config_beauty: $VK_result"

echo ""
echo "3.2.  Создание файла PATH_RESULT с содержимым vk_result:"
echo "$vk_result" > $PATH_RESULT
