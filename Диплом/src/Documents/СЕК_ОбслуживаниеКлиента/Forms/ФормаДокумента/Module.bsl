
#Область ОбработчикиСобытийФормы

&НаКлиенте
Процедура ПриПовторномОткрытии()
	Объект.МенялсяРеквизит = Ложь;
КонецПроцедуры 

&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	
	Если Объект.ВремяНачалаРабот >= Объект.ВремяОкончанияРабот Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Неверно задан период исполения заказа";
		Сообщение.Поле = Объект.ВремяНачалаРабот;
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		
		Отказ = Истина;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(Объект.Договор) Или Объект.Договор.ВидДоговора <> Перечисления.ВидыДоговоровКонтрагентов.СЕК_АбонентскоеОбслуживание Тогда
		
		Сообщение = Новый СообщениеПользователю;
		Сообщение.Текст = "Не выбран договор абонентского обслуживания";
		Сообщение.Поле = Объект.Договор;
		Сообщение.УстановитьДанные(ЭтотОбъект);
		Сообщение.Сообщить();
		
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура СпециалистПриИзменении(Элемент)
	Объект.МенялсяРеквизит = Истина;
КонецПроцедуры

&НаКлиенте
Процедура КлиентПриИзменении(Элемент)
	Объект.МенялсяРеквизит = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ДатаПроведенияРаботПриИзменении(Элемент)
	Объект.МенялсяРеквизит = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ВремяНачалаРаботПриИзменении(Элемент)
	Объект.МенялсяРеквизит = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ВремяОкончанияРаботПриИзменении(Элемент)
	Объект.МенялсяРеквизит = Истина;
КонецПроцедуры

&НаКлиенте
Процедура ОписаниеПроблемыПриИзменении(Элемент)
	Объект.МенялсяРеквизит = Истина;
КонецПроцедуры

#КонецОбласти