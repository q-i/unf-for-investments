# unf-for-investments
Использование 1С:УНФ для учёта инвестиций (вложений в акции, облигации и т.п.)

Методология учёта предполагается следующая:
* Тикер акции/облигации хранится в реквизите Артикул номенклатуры
* Рыночные котировки акций/облигаций хранятся в регистре Цены номенклатуры
* Операции покупки/продажи оформляются с помощью документов Приходная накладная/Расходная накладная

Набор предлагаемых инструментов включает:
* ВыгрузкаЗаявокВTRIФайл.epf - обработка для выгрузки документа Заказ поставщику в tri-файл для последующего импорта заявок в QUIK
* ЗагрузкаКотировокММВБ.epf - обработка для загрузки котировок МосБиржи
* ОценкаПортфеля.erf - отчёт для оценки инвестиционного портфеля (вывод рыночной оценки портфеля и долей бумаг в портфеле)
* ИнвестиционнаяДекларация.erf - отчёт для контроля инвестиционной декларации (плановые доли бумаг в портфеле задаются в спецификации; в отчёт выводятся фактические сведения о количестве, рыночной оценке и доле каждой из бумаг и разница между планом и фактом)
