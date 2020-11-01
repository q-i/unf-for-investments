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
	//Настройки.Размещение.Добавить(Метаданные.Документы.ПриходнаяНакладная);
	//Настройки.Размещение.Добавить(Метаданные.Документы.РасходнаяНакладная);
    Настройки.ДобавитьКомандыПечати = Истина;
КонецПроцедуры
// Заполняет список команд печати.
//
// Параметры:
//   КомандыПечати - ТаблицаЗначений - Подробнее см. в УправлениеПечатью.СоздатьКоллекциюКомандПечати().
//
Процедура ДобавитьКомандыПечати(КомандыПечати) Экспорт
	КомандаПечати = КомандыПечати.Добавить();
	КомандаПечати.Идентификатор = "Инв_ПечатьТабЧастиЗапасы";
	КомандаПечати.Представление = НСтр("ru = 'Инв: Печать тч Запасы'");
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
	
	ОписаниеПечатнойФормы = УправлениеПечатью.СведенияОПечатнойФорме(КоллекцияПечатныхФорм, "Инв_ПечатьТабЧастиЗапасы");
	Если ОписаниеПечатнойФормы <> Неопределено Тогда
		
		ОписаниеПечатнойФормы.ТабличныйДокумент = Новый ТабличныйДокумент;
		ОписаниеПечатнойФормы.ТабличныйДокумент.КлючПараметровПечати = "ПАРАМЕТРЫ_ПЕЧАТИ_Инв_ПечатьТабЧастиЗапасы";
		ОписаниеПечатнойФормы.ПолныйПутьКМакету = "Обработка.Инв_ПечатьТабЧастиЗапасы.ПФ_MXL_Запасы";
		ОписаниеПечатнойФормы.СинонимМакета = НСтр("ru ='Инв: Печать тч Запасы'");
		
		СформироватьПечатнуюФорму(ОписаниеПечатнойФормы, МассивОбъектов, ОбъектыПечати);
		
	КонецЕсли;
	
КонецПроцедуры

Функция СформироватьПечатнуюФорму(ОписаниеПечатнойФормы, МассивОбъектов, ОбъектыПечати)
	
	Перем ПервыйДокумент, НомерСтрокиНачало, Ошибки;
	
	ТабличныйДокумент	= ОписаниеПечатнойФормы.ТабличныйДокумент;
	Макет				= УправлениеПечатью.МакетПечатнойФормы(ОписаниеПечатнойФормы.ПолныйПутьКМакету);
	
	Если 1=2 Тогда
		ТабличныйДокумент = Новый ТабличныйДокумент;
		Макет = Новый ТабличныйДокумент;
	КонецЕсли;
	
	ОблЗаголовок = Макет.ПолучитьОбласть("Заголовок");
	ОблШапка = Макет.ПолучитьОбласть("Шапка");
	ОблСтрока = Макет.ПолучитьОбласть("Строка");
	ОблСтрокаПодитог = Макет.ПолучитьОбласть("СтрокаПодитог");
	ОблПодвал = Макет.ПолучитьОбласть("Подвал");
	
	ИмяДопРеквизитаРазмерЛота = "Инв_РазмерЛота";
	ДопРеквизитРазмерЛота = ПланыВидовХарактеристик.ДополнительныеРеквизитыИСведения.НайтиПоРеквизиту("Имя", ИмяДопРеквизитаРазмерЛота);
	Если НЕ ЗначениеЗаполнено(ДопРеквизитРазмерЛота) Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Не найден доп.реквизит номенклатуры с Имя = """ + ИмяДопРеквизитаРазмерЛота + """");
		Возврат ТабличныйДокумент;
	КонецЕсли;
	
	ИспользуемыеТипы = Новый Массив;
	ИспользуемыеТипы.Добавить(Тип("ДокументСсылка.ЗаказПоставщику"));
	//ИспользуемыеТипы.Добавить(Тип("ДокументСсылка.ПриходнаяНакладная"));
	//ИспользуемыеТипы.Добавить(Тип("ДокументСсылка.РасходнаяНакладная"));
	
	ПервыйДокумент = Истина;
	
	Для Каждого ТекТип Из ИспользуемыеТипы Цикл
		
		ТекМассивОбъектов = Новый Массив;
		Для Каждого ТекОбъект Из МассивОбъектов Цикл
			Если ТипЗнч(ТекОбъект) = ТекТип Тогда 
				ТекМассивОбъектов.Добавить(ТекОбъект);
			КонецЕсли;
		КонецЦикла;
		
		Если ТекМассивОбъектов.Количество() = 0 Тогда
			Продолжить;
		КонецЕсли;
		
		Запрос = Новый Запрос;
		Запрос.УстановитьПараметр("МассивОбъектов", ТекМассивОбъектов);
		Запрос.УстановитьПараметр("ДопРеквизитРазмерЛота", ДопРеквизитРазмерЛота);
		Запрос.УстановитьПараметр("ВидЦен", Справочники.ВидыЦен.ПолучитьОсновнойВидЦенПродажи());
		
		Запрос.Текст = 
		"ВЫБРАТЬ
		|	Запасы.Ссылка КАК Документ,
		|	Запасы.НомерСтроки КАК НомерСтроки,
		|	Запасы.Номенклатура КАК Номенклатура,
		|	Запасы.Количество КАК КоличествоВДокументе,
		|	Запасы.Цена КАК Цена,
		|	ВЫРАЗИТЬ(НоменклатураДополнительныеРеквизиты.Значение КАК ЧИСЛО(15, 2)) КАК РазмерЛота
		|ПОМЕСТИТЬ ВТ_Строки
		|ИЗ
		|	Документ.ЗаказПоставщику.Запасы КАК Запасы
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура.ДополнительныеРеквизиты КАК НоменклатураДополнительныеРеквизиты
		|		ПО Запасы.Номенклатура = НоменклатураДополнительныеРеквизиты.Ссылка
		|			И (НоменклатураДополнительныеРеквизиты.Свойство = &ДопРеквизитРазмерЛота)
		|ГДЕ
		|	Запасы.Ссылка В(&МассивОбъектов)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_Строки.Документ КАК Документ,
		|	ВТ_Строки.НомерСтроки КАК НомерСтроки,
		|	ВТ_Строки.Номенклатура КАК Номенклатура,
		|	ВТ_Строки.КоличествоВДокументе КАК КоличествоВДокументе,
		|	ВТ_Строки.Цена КАК Цена,
		|	ВТ_Строки.РазмерЛота КАК РазмерЛота,
		|	ВТ_Строки.КоличествоВДокументе * ВТ_Строки.РазмерЛота КАК КоличествоБумаг,
		|	ВТ_Строки.КоличествоВДокументе * ВТ_Строки.РазмерЛота * ВТ_Строки.Цена КАК Сумма,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК Котировка
		|ИЗ
		|	ВТ_Строки КАК ВТ_Строки
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|				,
		|				ВидЦен = &ВидЦен
		|					И Номенклатура В
		|						(ВЫБРАТЬ
		|							ВТ_Строки.Номенклатура
		|						ИЗ
		|							ВТ_Строки)
		|					И Характеристика = ЗНАЧЕНИЕ(Справочник.ХарактеристикиНоменклатуры.ПустаяСсылка)) КАК ЦеныНоменклатурыСрезПоследних
		|		ПО ВТ_Строки.Номенклатура = ЦеныНоменклатурыСрезПоследних.Номенклатура
		|
		|УПОРЯДОЧИТЬ ПО
		|	ВТ_Строки.Документ,
		|	НомерСтроки
		|ИТОГИ
		|	МИНИМУМ(НомерСтроки),
		|	МИНИМУМ(РазмерЛота),
		|	СУММА(КоличествоБумаг),
		|	СУММА(Сумма),
		|	МАКСИМУМ(Котировка)
		|ПО
		|	Документ,
		|	Номенклатура
		|АВТОУПОРЯДОЧИВАНИЕ";
		
		МетаДок = Метаданные.НайтиПоТипу(ТекТип);
		ИмяТаблицы = МетаДок.Имя;
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "Документ.ЗаказПоставщику.Запасы", "Документ." + ИмяТаблицы + ".Запасы");
		
		ВыборкаПоДокументам = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаПоДокументам.Следующий() Цикл
			
			Если ПервыйДокумент Тогда
				ПервыйДокумент = Ложь;
			Иначе
				ТабличныйДокумент.ВывестиГоризонтальныйРазделительСтраниц();
			КонецЕсли;
			
			ОблЗаголовок.Параметры.Заполнить(ВыборкаПоДокументам);
			ТабличныйДокумент.Вывести(ОблЗаголовок);
			ТабличныйДокумент.Вывести(ОблШапка);
			
			ВыборкаПоНоменклатуре = ВыборкаПоДокументам.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаПоНоменклатуре.Следующий() Цикл
				
				ОблСтрокаПодитог.Параметры.Заполнить(ВыборкаПоНоменклатуре);
				Если ЗначениеЗаполнено(ВыборкаПоНоменклатуре.РазмерЛота) Тогда
					ОблСтрокаПодитог.Параметры.Цена = ?(ВыборкаПоНоменклатуре.КоличествоБумаг <> 0,
														ВыборкаПоНоменклатуре.Сумма / ВыборкаПоНоменклатуре.КоличествоБумаг,
														0);
				Иначе
					ОблСтрокаПодитог.Параметры.Цена = "ОШИБКА!!! НЕ ЗАДАН РАЗМЕР ЛОТА!!!";
				КонецЕсли;
				ТабличныйДокумент.Вывести(ОблСтрокаПодитог);
				
				//ТабличныйДокумент.НачатьАвтогруппировкуСтрок();
				ТабличныйДокумент.НачатьГруппуСтрок("Номенклатура", Ложь);
				
				ВыборкаДетальная = ВыборкаПоНоменклатуре.Выбрать();
				Пока ВыборкаДетальная.Следующий() Цикл
					
					ОблСтрока.Параметры.Заполнить(ВыборкаДетальная);
					
					ОблСтрока.Область(1, 1, 1, 6).ЦветФона = ?(ВыборкаДетальная.Цена <= ВыборкаДетальная.Котировка,
																Новый Цвет,
																WebЦвета.СветлоКоралловый);
					
					ТабличныйДокумент.Вывести(ОблСтрока);
					
				КонецЦикла; // ВыборкаДетальная 
				
				ТабличныйДокумент.ЗакончитьГруппуСтрок();
				
				//ТабличныйДокумент.ЗакончитьАвтогруппировкуСтрок();
			
			КонецЦикла; // ВыборкаПоНоменклатуре
			
			ОблПодвал.Параметры.Заполнить(ВыборкаПоДокументам);
			ТабличныйДокумент.Вывести(ОблПодвал);
			
		КонецЦикла; // ВыборкаПоДокументам
		
	КонецЦикла; // Для Каждого ТекТип Из ИспользуемыеТипы Цикл
		
	Возврат ТабличныйДокумент;
	
КонецФункции
