﻿&НаКлиенте
Процедура Загрузить(Команда)
	
	Дата1 = Период.ДатаНачала;
	Дата2 = Период.ДатаОкончания;
	
	ЗагрузитьНаСервере();
	
	ПоказатьОповещениеПользователя("Загрузка котировок завершена!");
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьНаСервере()
	
	// http://export.rbc.ru/free/micex.0/free.fcgi?period=DAILY&tickers=NULL&d1=01&m1=08&y1=2017&d2=10&m2=08&y2=2017&lastdays=9&separator=%2C&data_format=EXCEL&header=1
	
	Сервер = "export.rbc.ru";
	АдресСтраницы = "/free/micex.0/free.fcgi?period=DAILY&tickers=[ТИКЕР]&d1=[ДД1]&m1=[ММ1]&y1=[ГГГГ1]&d2=[ДД2]&m2=[ММ2]&y2=[ГГГГ2]&separator=%2C&data_format=EXCEL&header=1";
	
	Замены = Новый Соответствие;
	Замены.Вставить("ТИКЕР", ?(ПустаяСтрока(Тикер), "NULL", СокрЛП(Тикер)));
	Замены.Вставить("ДД1", Формат(Дата1, "ДФ=dd"));
	Замены.Вставить("ММ1", Формат(Дата1, "ДФ=MM"));
	Замены.Вставить("ГГГГ1", Формат(Дата1, "ДФ=yyyy"));
	Замены.Вставить("ДД2", Формат(Дата2, "ДФ=dd"));
	Замены.Вставить("ММ2", Формат(Дата2, "ДФ=MM"));
	Замены.Вставить("ГГГГ2", Формат(Дата2, "ДФ=yyyy"));
	
	Для Каждого КлючИЗначение Из Замены Цикл
		АдресСтраницы = СтрЗаменить(АдресСтраницы, "[" + КлючИЗначение.Ключ + "]", КлючИЗначение.Значение);
	КонецЦикла; 
	
	УРЛ = "http://" + Сервер + АдресСтраницы;
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла();
	
	HTTPСоединение = Новый HTTPСоединение(Сервер);
	HTTPЗапрос = Новый HTTPЗапрос(АдресСтраницы);
	HTTPОтвет = HTTPСоединение.Получить(HTTPЗапрос, ИмяВременногоФайла);
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Сервер " + Сервер + " вернул код ошибки " + HTTPОтвет.КодСостояния);
		Возврат;
	КонецЕсли; 
	
	АртикулыНоменклатуры = Новый Соответствие; 
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка,
	|	Номенклатура.Артикул
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	НЕ Номенклатура.ЭтоГруппа
	|	И Номенклатура.Артикул <> """"";
	Если НЕ ПустаяСтрока(Тикер) Тогда
		Запрос.Текст = Запрос.Текст + "
		|	И Номенклатура.Артикул = &Тикер";
		Запрос.УстановитьПараметр("Тикер", Тикер);
	КонецЕсли; 
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Если ПустаяСтрока(Выборка.Артикул) Тогда
			Продолжить;
		КонецЕсли; 
		АртикулыНоменклатуры.Вставить(Выборка.Артикул, Выборка.Ссылка);
	КонецЦикла; 
	
	ЧтениеТекста = Новый ЧтениеТекста;
	ЧтениеТекста.Открыть(ИмяВременногоФайла);
	
	НомСтр = 0;
	
	НомераКолонок = Новый Структура;
	ПолеТикер = "TICKER";
	ПолеДата = "DATE";
	ПолеЦена = "CLOSE";
	
	Пока Истина Цикл
		
		Стр = ЧтениеТекста.ПрочитатьСтроку();
		Если Стр = Неопределено Тогда
			Прервать;
		КонецЕсли; 
		
		НомСтр = НомСтр + 1;
		
		Если ПустаяСтрока(Стр) Тогда
			Продолжить;
		КонецЕсли; 
		
		НачалоСообщенияОбОшибке = "Ошибка формата файла! Строка #" + НомСтр + ": ";
		
		МассивКомпонент = СтроковыеФункцииКлиентСервер.РазложитьСтрокуВМассивПодстрок(Стр, ",");
		
		Если НомСтр = 1 Тогда
			// в первой строке заголовки
			Для Сч = 0 По МассивКомпонент.Количество() - 1 Цикл
				ТекКомпонент = МассивКомпонент[Сч];
				Если ТекКомпонент = ПолеТикер Тогда
					НомераКолонок.Вставить("Тикер", Сч);
				ИначеЕсли ТекКомпонент = ПолеДата Тогда
					НомераКолонок.Вставить("Дата", Сч);
				ИначеЕсли ТекКомпонент = ПолеЦена Тогда
					НомераКолонок.Вставить("Цена", Сч);
				КонецЕсли; 
			КонецЦикла;
			Если НЕ НомераКолонок.Свойство("Тикер") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НачалоСообщенияОбОшибке + " В заголовке не найдено поле " + ПолеТикер + "!");
				Возврат;
			КонецЕсли; 
			Если НЕ НомераКолонок.Свойство("Дата") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НачалоСообщенияОбОшибке + " В заголовке не найдено поле " + ПолеДата + "!");
				Возврат;
			КонецЕсли; 
			Если НЕ НомераКолонок.Свойство("Цена") Тогда
				ОбщегоНазначенияКлиентСервер.СообщитьПользователю(НачалоСообщенияОбОшибке + " В заголовке не найдено поле " + ПолеЦена + "!");
				Возврат;
			КонецЕсли; 
		Иначе 
			ТекТикер = МассивКомпонент[НомераКолонок.Тикер];
			ТекНоменклатура = АртикулыНоменклатуры.Получить(ТекТикер);
			Если ТекНоменклатура = Неопределено Тогда
				Продолжить;
			КонецЕсли; 
			ТекДата = Дата(СтрЗаменить(МассивКомпонент[НомераКолонок.Дата], "-", ""));
			ТекЦена = Число(МассивКомпонент[НомераКолонок.Цена]);
			
			НЗ = РегистрыСведений.ЦеныНоменклатуры.СоздатьМенеджерЗаписи();
			НЗ.Период = ТекДата;
			НЗ.ВидЦен = ВидЦен;
			НЗ.Номенклатура = ТекНоменклатура;
			НЗ.Характеристика = Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка();
			НЗ.Цена = ТекЦена;
			НЗ.Актуальность = Истина;
			НЗ.Записать();
			
			ОбщегоНазначенияКлиентСервер.СообщитьПользователю("Тикер = " + ТекТикер + "; Дата = " + ТекДата + "; Цена = " + ТекЦена);
			
		КонецЕсли; 
		
	КонецЦикла; 
	
	ЧтениеТекста.Закрыть();
	
	УдалитьФайлы(ИмяВременногоФайла);
	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	//ВидЦен = Справочники.ВидыЦен.Учетная;
	
КонецПроцедуры
