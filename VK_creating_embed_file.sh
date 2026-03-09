#!/bin/bash

# 1. Из HTML шаблона файла встраивания извлекаем window.RT_WIDGET_CONFIG                                    -> rt_widget_config
# 2. Минифицируем rt_widget_config                                                                          -> rt_widget_config_minified
# 3. Загружаем JSON для встраивания                                                                         -> json_response
# 4. Минифицируем json_response                                                                             -> json_response_minified
# 5. Убираем внешние фигурные скобки у json_response_minified                                               -> json_response_list_pairs
# 6. В rt_widget_config_minified заменяем "placeholder_json_response": "value" на json_response_list_pairs  -> rt_widget_config_change1
# 7. Преобразуем rt_widget_config_change1 в удобочитаемый вид rt_widget_config_beauty                       -> rt_widget_config_pretty
# 8. В rt_widget_config_pretty заменяем "function(){}" на function () {}
# 9. Копируем файл HTML шаблона в целевой файл
#
#
#

# Объявление констант
PATH_JSON="/home/ruslan/Documents/RTK_IT/productOfferCfg_1.json"
PATH_TEMPLATE="/home/ruslan/Documents/RTK_IT/Template_html_1.html"
PATH_HTML="/home/ruslan/Documents/RTK_IT/VK_html.html"

echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение PATH_JSON: $PATH_JSON"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение PATH_TEMPLATE: $PATH_TEMPLATE"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение PATH_HTML: $PATH_HTML"

echo ""
echo "1. Извлекаем текущую конфигурацию rt_widget_config из HTML:"
# Извлекаем текущую конфигурацию из HTML    <script>window.RT_WIDGET_CONFIG = {}</script>
# Поиск с учетом вложенности (более надежный) Этот вариант использует рекурсивный regex и правильно обработает вложенные объекты
rt_widget_config=$(perl -0777 -ne 'while (/window\.RT_WIDGET_CONFIG = ({((?>[^{}]+|(?1))*)})/g) { print $1 }' $PATH_TEMPLATE)
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config: $rt_widget_config"

echo ""
echo "2. Минифицируем rt_widget_config:"
rt_widget_config_minified=$(echo "$rt_widget_config" | jq -c .)
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config_minified: $rt_widget_config_minified"

echo ""
echo "3. Загружаем JSON для встраивания:"
json_response=$(cat "$PATH_JSON")

echo ""
echo "4. Минифицируем json_response:"
json_response_minified=$(echo "$json_response" | jq -c .)
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение json_response_minified: $json_response_minified"

echo ""
echo "5. Убираем внешние фигурные скобки у json_response_minified:"
json_response_list_pairs="${json_response_minified:1:-1}"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение json_response_list_pairs: $json_response_list_pairs"

echo ""
echo "6. В rt_widget_config_minified заменяем "placeholder_json_response": "value" на json_response_list_pairs"
rt_widget_config_change1="${rt_widget_config_minified//\"placeholder_json_response\":\"value\"/$json_response_list_pairs}"
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config_change1: $rt_widget_config_change1"

echo ""
echo "7. Преобразуем rt_widget_config_change1 в удобочитаемый вид rt_widget_config_pretty"
rt_widget_config_pretty=$(echo "$rt_widget_config_change1" | jq '.')
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config_pretty: $rt_widget_config_pretty"

echo ""
echo "8. В rt_widget_config_pretty заменяем \"function(){}\" на function () {}"
rt_widget_config=${rt_widget_config_pretty//"\"function(){}\""/function () \{ \}}
echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config: $rt_widget_config"

echo ""
echo "9. Копируем файл HTML шаблона $PATH_TEMPLATE в целевой файл $PATH_HTML"
cp "$PATH_TEMPLATE" "$PATH_HTML"


# echo "Экранируем значение для вставки в JSON"
# escaped_config=$(echo "$rt_widget_config" | jq -R -s '.')
# echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение escaped_config: $escaped_config"

echo ""
echo "11. В целевом файле $PATH_HTML меняем значение window.RT_WIDGET_CONFIG на rt_widget_config"
# perl -i -0777 -pe 's/(window\.RT_WIDGET_CONFIG = )({((?>[^{}]+|(?1))*)})/$1$ENV{rt_widget_config}/g' "$PATH_HTML"
# perl -i -0777 -pe "s/(window\.RT_WIDGET_CONFIG = )({((?>[^{}]+|(?1))*)})/\$1$rt_widget_config/g" "$PATH_HTML"
# perl -i -0777 -pe 's/(window\.RT_WIDGET_CONFIG = )({((?>[^{}]+|(?1))*)})/$1$ARGV[0]/g' "$rt_widget_config" "$PATH_HTML"
perl -i -0777 -pe 's/(window\.RT_WIDGET_CONFIG = )({((?>[^{}]+|(?1))*)})/$1 . quotemeta($ENV{rt_widget_config})/ge' \
  -e "BEGIN { \$ENV{rt_widget_config} = '$rt_widget_config' }" "$PATH_HTML"

# Заменяем placeholder
# json_response=$(echo "$json_response" | jq --arg new "$escaped_config" '.widget_config = $new')

echo ""
# echo "$(date '+%Y-%m-%d %H:%M:%S') - Значение rt_widget_config: $rt_widget_config"
echo ""


# Замена $json_response на содержимое JSON в файле
# Используем | как разделитель в sed, чтобы избежать проблем с символами / в JSON
# sed -i "s|\\\$json_response|$json_response|g" "$PATH_HTML"

# echo "Скрипт успешно выполнен. JSON вставлен в файл: $PATH_HTML"



# не работают или работают плохо:
# current_config=$(grep -o 'window\.RT_WIDGET_CONFIG = {[^}]*}' /home/ruslan/Documents/RTK_IT/Template_html_1.html)
# current_config=$(perl -0777 -ne 'print "$&\n" if /window\.RT_WIDGET_CONFIG = {.*?}/s' /home/ruslan/Documents/RTK_IT/Template_html_1.html)
# current_config=$(sed -n '/window\.RT_WIDGET_CONFIG = {/,/^}$/p' $PATH_TEMPLATE)