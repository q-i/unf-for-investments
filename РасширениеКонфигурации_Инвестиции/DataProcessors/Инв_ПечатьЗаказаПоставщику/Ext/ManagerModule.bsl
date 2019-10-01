﻿

#Область ПрограммныйИнтерфейс
// Определяет состав программного интерфейса для интеграции с конфигурацией.
//
// Параметры:
//   Настройки - Структура - Настройки интеграции этого объекта.
//       См. возвращаемое значение функции ПодключаемыеКоманды.НастройкиПодключаемыхОтчетовИОбработок().
//
Процедура ПриОпределенииНастроек(Настройки) Экспорт
    Настройки.Размещение.Добавить(Метаданные.Документы.ЗаказПоставщику);
    Настройки.ДобавитьКомандыПечати = Истина;
КонецПроцедуры
// Заполняет список команд печати.
//
// Параметры:
//   КомандыПечати - ТаблицаЗначений - Подробнее см. в УправлениеПечатью.СоздатьКоллекциюКомандПечати().
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "Инв_ЗаказПоставщику";
	КомандаПечати.Представление = НСтр("ru = 'Инв: Заказ поставщику'");
	КомандаПечати.ПроверкаПроведенияПередПечатью = Ложь;
	КомандаПечати.Порядок = 999;
КонецПроцедуры
#КонецОбласти
// Формирует печатные формы.
//
// Параметры:
//  МассивОбъектов - Массив - ссылки на объекты, которые нужно распечатать;
//  ПараметрыПечати - Структура - дополнительные настройки печати;
//  КоллекцияПечатныхФорм - ТаблицаЗначений - сформированные табличные документы (выходной параметр)
//  ОбъектыПечати - СписокЗначений - значение - ссылка на объект;
//                                            представление - имя области, в которой был выведен объект (выходной параметр);
//  ПараметрыВывода - Структура - дополнительные параметры сформированных табличных документов (выходной параметр).
//
Процедура Печать(МассивОбъектов, ПараметрыПечати, КоллекцияПечатныхФорм, ОбъектыПечати, ПараметрыВывода) Экспорт
	
	ОписаниеПечатнойФормы = УправлениеПечатью.СведенияОПечатнойФорме(КоллекцияПечатныхФорм, "Инв_ЗаказПоставщику");
	Если ОписаниеПечатнойФормы <> Неопределено Тогда
		
		ОписаниеПечатнойФормы.ТабличныйДокумент = Новый ТабличныйДокумент;
		ОписаниеПечатнойФормы.ТабличныйДокумент.КлючПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_ЗаказПоставщику_Инв_ЗаказПоставщику";
		ОписаниеПечатнойФормы.ПолныйПутьКМакету = "Обработка.Инв_ПечатьЗаказаПоставщику.ПФ_MXL_ЗаказПоставщику";
		ОписаниеПечатнойФормы.СинонимМакета = НСтр("ru ='Инв: Заказ поставщику'");
		
		СформироватьЗаказПоставщику(ОписаниеПечатнойФормы, МассивОбъектов, ОбъектыПечати);
		
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьЗаказПоставщику(ОписаниеПечатнойФормы, МассивОбъектов, ОбъектыПечати)
	
	Перем ПервыйДокумент, НомерСтрокиНачало, Ошибки;
	
	ТабличныйДокумент	= ОписаниеПечатнойФормы.ТабличныйДокумент;
	Макет				= УправлениеПечатью.МакетПечатнойФормы(ОписаниеПечатнойФормы.ПолныйПутьКМакету);
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("МассивОбъектов", МассивОбъектов);
	Запрос.УстановитьПараметр("ДопСвойствоРазмерЛота", ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", "Инв_РазмерЛота"));
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЗаказПоставщикуЗапасы.Номенклатура КАК Номенклатура,
	|	ЗаказПоставщикуЗапасы.Количество КАК Количество,
	|	ЗаказПоставщикуЗапасы.Цена КАК Цена,
	|	НоменклатураДополнительныеРеквизиты.Значение КАК РазмерЛота
	|ИЗ
	|	Документ.ЗаказПоставщику.Запасы КАК ЗаказПоставщикуЗапасы
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
	|		ПО ЗаказПоставщикуЗапасы.Номенклатура = НоменклатураДополнительныеРеквизиты.Ссылка
	|			И (НоменклатураДополнительныеРеквизиты.Свойство = &ДопСвойствоРазмерЛота)
	|ГДЕ
	|	ЗаказПоставщикуЗапасы.Ссылка В(&МассивОбъектов)
	|
	|УПОРЯДОЧИТЬ ПО 
	|	ЗаказПоставщикуЗапасы.Ссылка,
	|	ЗаказПоставщикуЗапасы.НомерСтроки";
	
	ОблШапка = Макет.ПолучитьОбласть("Шапка");
	ОблСтрока = Макет.ПолучитьОбласть("Строка");
	ОблПодвал = Макет.ПолучитьОбласть("Подвал");
	
	ТабличныйДокумент.Вывести(ОблШапка);
	
	СуммаИтого = 0;
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		
		ОблСтрока.Параметры.Заполнить(Выборка);
		
		Сумма = Выборка.Количество * Выборка.РазмерЛота * Выборка.Цена;
		ОблСтрока.Параметры.Сумма = Сумма;
		
		СуммаИтого = СуммаИтого + Сумма;
		
		ТабличныйДокумент.Вывести(ОблСтрока);
		
	КонецЦикла;
	
	ОблПодвал.Параметры.Сумма = СуммаИтого;
	ТабличныйДокумент.Вывести(ОблПодвал);
	
	Возврат ТабличныйДокумент;
	
КонецФункции // ПечатнаяФорма()
