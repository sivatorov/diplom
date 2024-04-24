
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда  

#Область ОбработчикиСобытийМодуляОбъекта

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Для Каждого Строка Из Сотрудники Цикл
		Если Месяц(Строка.ДатаНачала) <> Месяц(Строка.ДатаОкончания) Тогда
			Сообщить (СтрШаблон("Не верно задан период в строке №%1", Строка.НомерСтроки));
			Отказ = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)
	
	СформироватьДвиженияОсновныеНачисления();
	
	СформироватьСторноЗаписи();
	
	Движения.СЕК_ОсновныеНачисления.Записать();
	
	РасчетОклада();
	
	РасчетОтпуска();
	
	РасчетУдержаний();
	
	СформироватьДвиженияВзаиморасчетыССотрудниками();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыФункции

Процедура СформироватьДвиженияОсновныеНачисления() 
	
	Если Сотрудники.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	МинимальнаяДатаНачала = Неопределено;
	МаксимальнаяДатаОкончания = Неопределено;
	
	Для каждого Строка Из Сотрудники Цикл
		Если Не ЗначениеЗаполнено(МинимальнаяДатаНачала)
			Или МинимальнаяДатаНачала > Строка.ДатаНачала Тогда
			МинимальнаяДатаНачала = Строка.ДатаНачала;
		КонецЕсли;
		
		Если Не ЗначениеЗаполнено(МаксимальнаяДатаОкончания)
			ИЛИ МаксимальнаяДатаОкончания < Строка.ДатаОкончания  Тогда
			МаксимальнаяДатаОкончания = Строка.ДатаОкончания;
		КонецЕсли;
	КонецЦикла;
	
	Движения.СЕК_ОсновныеНачисления.Записывать = Истина;
	Движения.СЕК_Удержания.Записывать = Истина;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	СЕК_НачислениеЗарплатыСотрудники.Сотрудник КАК Сотрудник,
		|	СЕК_НачислениеЗарплатыСотрудники.ВидРасчета КАК ВидРасчета,
		|	СЕК_НачислениеЗарплатыСотрудники.ДатаНачала КАК ДатаНачала,
		|	СЕК_НачислениеЗарплатыСотрудники.ДатаОкончания КАК ДатаОкончания,
		|	СЕК_НачислениеЗарплатыСотрудники.ГрафикРаботы КАК ГрафикРаботы,
		|	СЕК_НачислениеЗарплаты.Подразделение КАК Подразделение
		|ПОМЕСТИТЬ ВТ_ДанныеДокумента
		|ИЗ
		|	Документ.СЕК_НачислениеЗарплаты.Сотрудники КАК СЕК_НачислениеЗарплатыСотрудники
		|		ЛЕВОЕ СОЕДИНЕНИЕ Документ.СЕК_НачислениеЗарплаты КАК СЕК_НачислениеЗарплаты
		|		ПО СЕК_НачислениеЗарплатыСотрудники.Ссылка = СЕК_НачислениеЗарплаты.Ссылка
		|ГДЕ
		|	СЕК_НачислениеЗарплатыСотрудники.Ссылка = &Ссылка
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СЕК_УсловияОплатыСотрудниковСрезПоследних.Оклад КАК Оклад,
		|	СЕК_УсловияОплатыСотрудниковСрезПоследних.ПроцентОтРабот КАК ПроцентОтРабот,
		|	СЕК_УсловияОплатыСотрудниковСрезПоследних.Сотрудник КАК Сотрудник,
		|	СЕК_УсловияОплатыСотрудниковСрезПоследних.Подразделение КАК Подразделение
		|ПОМЕСТИТЬ ВТ_ОкладПроцент
		|ИЗ
		|	РегистрСведений.СЕК_УсловияОплатыСотрудников.СрезПоследних(
		|			&ДатаНачала,
		|			Сотрудник В
		|				(ВЫБРАТЬ
		|					ВТ_ДанныеДокумента.Сотрудник КАК Сотрудник
		|				ИЗ
		|					ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента)) КАК СЕК_УсловияОплатыСотрудниковСрезПоследних
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	СЕК_ВыполненныеСотрудникомРаботыОбороты.СуммаКОплатеОборот КАК СуммаКОплатеОборот,
		|	СЕК_ВыполненныеСотрудникомРаботыОбороты.Специалист КАК Специалист
		|ПОМЕСТИТЬ ВТ_ПроцентОтРабот
		|ИЗ
		|	РегистрНакопления.СЕК_ВыполненныеСотрудникомРаботы.Обороты(
		|			&ДатаНачала,
		|			&ДатаОкончания,
		|			,
		|			Специалист В
		|				(ВЫБРАТЬ
		|					ВТ_ДанныеДокумента.Сотрудник КАК Сотрудник
		|				ИЗ
		|					ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента)) КАК СЕК_ВыполненныеСотрудникомРаботыОбороты
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ДанныеДокумента.Сотрудник КАК Сотрудник,
		|	ВТ_ДанныеДокумента.ВидРасчета КАК ВидРасчета,
		|	ВТ_ДанныеДокумента.ДатаНачала КАК ДатаНачала,
		|	ВТ_ДанныеДокумента.ДатаОкончания КАК ДатаОкончания,
		|	ВТ_ДанныеДокумента.ГрафикРаботы КАК ГрафикРаботы,
		|	ВЫБОР
		|		КОГДА ВТ_ДанныеДокумента.ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.СЕК_ОсновныеНачисления.Оклад)
		|			ТОГДА ВТ_ОкладПроцент.Оклад
		|		КОГДА ВТ_ДанныеДокумента.ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.СЕК_ОсновныеНачисления.ПроцентОтРабот)
		|			ТОГДА ВТ_ОкладПроцент.ПроцентОтРабот
		|		ИНАЧЕ НЕОПРЕДЕЛЕНО
		|	КОНЕЦ КАК Показатель,
		|	-ВТ_ПроцентОтРабот.СуммаКОплатеОборот КАК СуммаПроцентовЗаРаботу
		|ИЗ
		|	ВТ_ДанныеДокумента КАК ВТ_ДанныеДокумента
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ОкладПроцент КАК ВТ_ОкладПроцент
		|		ПО ВТ_ДанныеДокумента.Сотрудник = ВТ_ОкладПроцент.Сотрудник
		|			И ВТ_ДанныеДокумента.Подразделение = ВТ_ОкладПроцент.Подразделение
		|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ПроцентОтРабот КАК ВТ_ПроцентОтРабот
		|		ПО ВТ_ДанныеДокумента.Сотрудник = ВТ_ПроцентОтРабот.Специалист";
	
	Запрос.УстановитьПараметр("ДатаНачала", МинимальнаяДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", МаксимальнаяДатаОкончания);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.СЕК_ОсновныеНачисления.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.Подразделение = Подразделение;
		Движение.ВидРасчета = Выборка.ВидРасчета;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.ГрафикРаботы = Выборка.ГрафикРаботы;
		Движение.ПериодДействияНачало = Выборка.ДатаНачала;
		Движение.ПериодДействияКонец = Выборка.ДатаОкончания;
		Движение.Показатель = Выборка.Показатель; 
		
		Если Движение.ВидРасчета = ПланыВидовРасчета.СЕК_ОсновныеНачисления.Отпуск Тогда
			Движение.БазовыйПериодНачало = НачалоМесяца(ДобавитьМесяц(Движение.ПериодДействияНачало, -12));
			Движение.БазовыйПериодКонец = КонецМесяца(ДобавитьМесяц(Движение.БазовыйПериодНачало, 11));
			Движение.ДнейОтработано = (Движение.ПериодДействияКонец - Движение.ПериодДействияНачало)/86400 + 1;
			Движение.Показатель = Неопределено; 
		КонецЕсли; 
		
		Если Движение.ВидРасчета = ПланыВидовРасчета.СЕК_ОсновныеНачисления.ПроцентОтРабот Тогда
			Движение.Показатель = Выборка.Показатель;
			Движение.Сумма = Выборка.СуммаПроцентовЗаРаботу;
			Движение.ДнейОтработано = Неопределено; 
		КонецЕсли;
		
	КонецЦикла;
	
	СформироватьДвиженияУдержания();
	
	Движения.СЕК_ОсновныеНачисления.Записать();
	Движения.СЕК_Удержания.Записать();
	
КонецПроцедуры

Процедура СформироватьДвиженияУдержания()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	СЕК_НачислениеЗарплатыСотрудники.Сотрудник КАК Сотрудник
	|ИЗ
	|	Документ.СЕК_НачислениеЗарплаты.Сотрудники КАК СЕК_НачислениеЗарплатыСотрудники
	|ГДЕ
	|	СЕК_НачислениеЗарплатыСотрудники.Ссылка = &Ссылка";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.СЕК_Удержания.Добавить();
		Движение.ПериодРегистрации = Дата;
		Движение.ВидРасчета = ПланыВидовРасчета.СЕК_Удержания.НДФЛ;
		Движение.Сотрудник = Выборка.Сотрудник;  
		Движение.Подразделение = Подразделение; 
		Движение.БазовыйПериодНачало = НачалоМесяца(Дата);
		Движение.БазовыйПериодКонец = КонецМесяца(Дата);
	КонецЦикла;
	
КонецПроцедуры

Процедура СформироватьСторноЗаписи()
	
	СторноЗаписи = Движения.СЕК_ОсновныеНачисления.ПолучитьДополнение();
	
	Для Каждого Запись Из СторноЗаписи Цикл
		
		Движение = Движения.СЕК_ОсновныеНачисления.Добавить();
		ЗаполнитьЗначенияСвойств(Движение, Запись);
		Движение.ПериодРегистрации = Дата; 
		Движение.ПериодДействияНачало = Запись.ПериодДействияНачалоСторно;
		Движение.ПериодДействияКонец = Запись.ПериодДействияКонецСторно;
		Движение.Сторно = Истина; 
		
	КонецЦикла;
	
КонецПроцедуры

Процедура РасчетОклада()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЕСТЬNULL(СЕК_ОсновныеНачисленияДанныеГрафика.ДнейПериодДействия, 0) КАК План,
		|	ЕСТЬNULL(СЕК_ОсновныеНачисленияДанныеГрафика.ДнейФактическийПериодДействия, 0) КАК Факт,
		|	СЕК_ОсновныеНачисленияДанныеГрафика.Сотрудник КАК Сотрудник,
		|	СЕК_ОсновныеНачисленияДанныеГрафика.Подразделение КАК Подразделение,
		|	СЕК_ОсновныеНачисленияДанныеГрафика.ВидРасчета КАК ВидРасчета,
		|	СЕК_ОсновныеНачисленияДанныеГрафика.НомерСтроки КАК НомерСтроки
		|ИЗ
		|	РегистрРасчета.СЕК_ОсновныеНачисления.ДанныеГрафика(
		|			ВидРасчета = ЗНАЧЕНИЕ(ПланВидовРасчета.СЕК_ОсновныеНачисления.Оклад)
		|				И Регистратор = &Ссылка) КАК СЕК_ОсновныеНачисленияДанныеГрафика";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.СЕК_ОсновныеНачисления[Выборка.НомерСтроки - 1];
		Движение.ДнейОтработано = Выборка.Факт; 
		Движение.Сумма =  Движение.Показатель * Выборка.Факт / Выборка.План;
		
		Если Движение.Сторно Тогда
			Движение.ДнейОтработано = -Движение.ДнейОтработано;
			Движение.Сумма = - Движение.Сумма;
		КонецЕсли;
	КонецЦикла;
	
	Движения.СЕК_ОсновныеНачисления.Записать(, Истина);
	
КонецПроцедуры

Процедура РасчетОтпуска()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СЕК_ОсновныеНачисления.НомерСтроки КАК НомерСтроки,
	|	СЕК_ОсновныеНачисления.Сотрудник КАК Сотрудник,
	|	СЕК_ОсновныеНачисления.ВидРасчета КАК ВидРасчета,
	|	ЕСТЬNULL(СЕК_ОсновныеНачисленияБазаСЕК_ОсновныеНачисления.ДнейОтработано, 0) КАК ДнейОтпуска,
	|	ЕСТЬNULL(СЕК_ОсновныеНачисленияБазаСЕК_ОсновныеНачисления.СуммаБаза, 0) КАК СуммаНачислений,
	|	ЕСТЬNULL(СЕК_ОсновныеНачисленияДанныеГрафика.ДнейБазовыйПериод, 0) КАК ОтработаноДней
	|ИЗ
	|	РегистрРасчета.СЕК_ОсновныеНачисления КАК СЕК_ОсновныеНачисления
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.СЕК_ОсновныеНачисления.БазаСЕК_ОсновныеНачисления(
	|				&Измерения,
	|				&Измерения,
	|				,
	|				ВидРасчета = &Отпуск
	|					И Регистратор = &Ссылка) КАК СЕК_ОсновныеНачисленияБазаСЕК_ОсновныеНачисления
	|		ПО СЕК_ОсновныеНачисления.НомерСтроки = СЕК_ОсновныеНачисленияБазаСЕК_ОсновныеНачисления.НомерСтроки
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.СЕК_ОсновныеНачисления.ДанныеГрафика(
	|				ВидРасчета = &Отпуск
	|					И Регистратор = &Ссылка) КАК СЕК_ОсновныеНачисленияДанныеГрафика
	|		ПО СЕК_ОсновныеНачисления.НомерСтроки = СЕК_ОсновныеНачисленияДанныеГрафика.НомерСтроки
	|ГДЕ
	|	СЕК_ОсновныеНачисления.ВидРасчета = &Отпуск
	|	И СЕК_ОсновныеНачисления.Регистратор = &Ссылка";
	
	Измерения = Новый Массив;
	Измерения.Добавить("Сотрудник");
	Измерения.Добавить("Подразделение");
	Запрос.УстановитьПараметр("Измерения", Измерения);
	Запрос.УстановитьПараметр("Отпуск", ПланыВидовРасчета.СЕК_ОсновныеНачисления.Отпуск);
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.СЕК_ОсновныеНачисления[Выборка.НомерСтроки - 1];
		Движение.Показатель = Выборка.СуммаНачислений / Выборка.ОтработаноДней;
		Движение.Сумма = Движение.Показатель * Выборка.ДнейОтпуска;
		
		Если Движение.Сторно Тогда
			Движение.Сумма = -Движение.Сумма;
		КонецЕсли;
	КонецЦикла;
	
	Движения.СЕК_ОсновныеНачисления.Записать(, Истина);
	
КонецПроцедуры

Процедура РасчетУдержаний()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СЕК_Удержания.НомерСтроки КАК НомерСтроки,
	|	ЕСТЬNULL(СЕК_УдержанияБазаСЕК_ОсновныеНачисления.СуммаБаза, 0) КАК СуммаБаза
	|ИЗ
	|	РегистрРасчета.СЕК_Удержания КАК СЕК_Удержания
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.СЕК_Удержания.БазаСЕК_ОсновныеНачисления(
	|				&Измерения,
	|				&Измерения,
	|				,
	|				Регистратор = &Ссылка
	|					И ВидРасчета = &ВидРасчета) КАК СЕК_УдержанияБазаСЕК_ОсновныеНачисления
	|		ПО СЕК_Удержания.НомерСтроки = СЕК_УдержанияБазаСЕК_ОсновныеНачисления.НомерСтроки
	|ГДЕ
	|	СЕК_Удержания.Регистратор = &Ссылка"; 
	
	Измерение = Новый Массив; 
	Измерение.Добавить("Сотрудник");
	Измерение.Добавить("Подразделение");
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	Запрос.УстановитьПараметр("Измерения", Измерение);
	Запрос.УстановитьПараметр("ВидРасчета", ПланыВидовРасчета.СЕК_Удержания.НДФЛ);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.СЕК_Удержания[Выборка.НомерСтроки - 1];
		Движение.Сумма = Выборка.СуммаБаза * 13 / 100;
	КонецЦикла;
	
	Движения.СЕК_Удержания.Записать(,Истина);
	
КонецПроцедуры

Процедура СформироватьДвиженияВзаиморасчетыССотрудниками()
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	СЕК_ОсновныеНачисления.Сотрудник КАК Сотрудник,
	|	СЕК_ОсновныеНачисления.Подразделение КАК Подразделение,
	|	СУММА(СЕК_ОсновныеНачисления.Сумма) КАК Оклад,
	|	СЕК_Удержания.Сумма КАК НДФЛ
	|ИЗ
	|	РегистрРасчета.СЕК_ОсновныеНачисления КАК СЕК_ОсновныеНачисления
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрРасчета.СЕК_Удержания КАК СЕК_Удержания
	|		ПО СЕК_ОсновныеНачисления.Сотрудник = СЕК_Удержания.Сотрудник
	|ГДЕ
	|	СЕК_ОсновныеНачисления.Регистратор = &Ссылка
	|	И СЕК_Удержания.Регистратор = &Ссылка
	|
	|СГРУППИРОВАТЬ ПО
	|	СЕК_ОсновныеНачисления.Сотрудник,
	|	СЕК_ОсновныеНачисления.Подразделение,
	|	СЕК_Удержания.Сумма
	|ИТОГИ
	|	СУММА(Оклад),
	|	СУММА(НДФЛ)
	|ПО
	|	Сотрудник";
	
	Запрос.УстановитьПараметр("Ссылка", Ссылка);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Выборка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам, "Сотрудник");
	
	Пока Выборка.Следующий() Цикл
		Движение = Движения.СЕК_ВзаиморасчетыССотрудниками.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Приход; 
		Движение.Период = Дата;
		Движение.Подразделение = Подразделение;
		Движение.Сотрудник = Выборка.Сотрудник;
		Движение.Сумма = Выборка.Оклад - Выборка.НДФЛ;
	КонецЦикла;
	
	Движения.СЕК_ВзаиморасчетыССотрудниками.Записать();
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли

