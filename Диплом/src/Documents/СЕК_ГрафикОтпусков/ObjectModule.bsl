
#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда  

#Область ОбработчикиСобытий

Процедура ОбработкаПроверкиЗаполнения(Отказ, ПроверяемыеРеквизиты)
	
	Для каждого Строка Из ОтпускаСотрудников Цикл
		
		Если ЗначениеЗаполнено (Строка.ДатаНачала) И ЗначениеЗаполнено(Строка.ДатаОкончания) Тогда
			Если Строка.ДатаНачала > Строка.ДатаОкончания Тогда
				ОбщегоНазначения.СообщитьПользователю(СтрШаблон("Неверно заполнен период в строке №%1",
					Строка.НомерСтроки));
				Отказ = Истина;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	
	Набор = РегистрыСведений.СЕК_ГрафикиОтпусков.СоздатьНаборЗаписей();
	Сутки = 60 * 60 * 24;
	
	Для Каждого Строка Из ОтпускаСотрудников Цикл
		День = Строка.ДатаНачала;
		Пока День < Строка.ДатаОкончания + 1 Цикл
			НоваяЗапись = Набор.Добавить();
			НоваяЗапись.Дата = День;
			НоваяЗапись.Сотрудник = Строка.Сотрудник;
			НоваяЗапись.Значение = 1; 
			День = День + Сутки;
		КонецЦикла;
	КонецЦикла;
	
	Набор.Записать(Ложь);
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли