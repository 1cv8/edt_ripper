#Использовать fs
#Использовать logos

#Область ОписаниеПеременных

Перем Лог; // Переменная для хранения логов
Перем Контекст; // Контекст (путь до файла с правилами))
Перем КонтекстОшибок; // Имя файла ошибок при проверке по правилам "rule-errors.log"
Перем ЗагрузчикПравил; // Инстанс загрузчика правил
Перем ЗаписьОшибокПравил; // Запись ошибок правил в файл (Истина/Ложь)
Перем КонтекстПараметров; // Контекст (путь до файла с параметрами проверки))

#КонецОбласти

#Область ПрограммныйИнтерфейс

// Возвращает объект лог для фиксации сообщений
//
//  Возвращаемое значение:
//   logos.Лог - объект типа
//
Функция Лог() Экспорт
	
	Если Лог = Неопределено Тогда
		Лог = Логирование.ПолучитьЛог(ИмяЛогаПриложения());
	КонецЕсли;
	
	Возврат Лог;
	
КонецФункции

// Возвращает контекст сохранения замечаний
//
//  Возвращаемое значение:
//   Строка - контекст для работы с сохранением правил
//
Функция ПолучитьКонтекст() Экспорт
	
	Если Не ЗначениеЗаполнено(Контекст) Тогда	
		Лог.Отладка("Установка котекста сохранения замечаний");
		УстановитьКонтекстСохранения(Неопределено);
	КонецЕсли;

	Возврат Контекст;

КонецФункции

// Устанавливает место, откуда будут читаться старые замечания и записываться новые.
//
// Параметры:
//   ПутьКФайлу - Строка - Путь к внешнему файлу правил
//
Процедура УстановитьКонтекстСохранения(Знач ПутьКФайлу) Экспорт

	ТипКонтекста = ?(ЗначениеЗаполнено(Контекст), "новый", "");

	Если ЗначениеЗаполнено(ПутьКФайлу) Тогда
		 Контекст = ФС.ПолныйПуть(ПутьКФайлу);
		 Сообщение = СтрШаблон("Установлен %1 контекст сохранения замечаний: %2", ТипКонтекста, Контекст);
		 Лог.Информация(СтрЗаменить(Сообщение, "  ", " "));
	Иначе
		Контекст = ФС.ПолныйПуть(ЛокальныйКонтекст());
		Лог.Информация("Установлен локальный контекст сохранения замечаний: %1", Контекст);
	КонецЕсли;

КонецПроцедуры

// Возвращает контекст сохранения ошибок
//
//  Возвращаемое значение:
//   Строка - контекст ошибок
//
Функция ПолучитьКонтекстОшибок() Экспорт
	
	Если Не ЗначениеЗаполнено(КонтекстОшибок) Тогда	
		Лог.Отладка("Установка контекста сохранения ошибок");
		УстановитьКонтекстСохраненияОшибок("");
	КонецЕсли;

	Возврат КонтекстОшибок;

КонецФункции

// Устанавливает путь до файла содержащего ошибки замечаний.
//
// Параметры:
//   ПутьКФайлу - Строка - Путь к внешнему файлу ошибок замечаний
//
Процедура УстановитьКонтекстСохраненияОшибок(Знач ПутьКФайлу) Экспорт

	Если ЗначениеЗаполнено(ПутьКФайлу) Тогда
		 КонтекстОшибок = ФС.ПолныйПуть(ПутьКФайлу);
		 Лог.Информация("Установлен новый контекст сохранения ошибок: %1", КонтекстОшибок);
	Иначе
		КонтекстОшибок = ФС.ПолныйПуть(ЛокальныйКонтекстОшибок());
		Лог.Информация("Установлен локальный контекст сохранения ошибок: %1", КонтекстОшибок);
	КонецЕсли;

КонецПроцедуры

// Путь к локальному файлу с сохраненными правилами
//
//  Возвращаемое значение:
//   Строка - Путь к файлу
//
Функция ЛокальныйКонтекст() Экспорт
	
	Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "../..", "custom-rules.json");

КонецФункции

// Путь к локальному файлу с ошибками замечаний
//
//  Возвращаемое значение:
//   Строка - Путь к файлу
//
Функция ЛокальныйКонтекстОшибок() Экспорт
	
	Возврат ОбъединитьПути(ТекущийСценарий().Каталог, "../..", "custom-rules-errors.json");

КонецФункции

// Возвращает имя лога приложения
//
//  Возвращаемое значение:
//   Строка - Имя лога
//
Функция ИмяЛогаПриложения() Экспорт
	Возврат "oscript.app." + ИмяПриложения();
КонецФункции

// Возвращает имя приложения
//
//  Возвращаемое значение:
//   Строка - Имя приложения
//
Функция ИмяПриложения() Экспорт
	Возврат "edt-ripper";
	
КонецФункции

// Версия приложения
//
//  Возвращаемое значение:
//   Строка - Строка с версией приложения
//
Функция Версия() Экспорт
	
	Возврат "24.03";
	
КонецФункции

// Устанавливает режим отладки для логирования приложения
//
// Параметры:
//   РежимОтладки - Булево - Если Истина отладка включается, если ложь - выключается
//
Процедура УстановитьРежимОтладки(Знач РежимОтладки) Экспорт
	
	Если РежимОтладки Тогда
		
		Лог().УстановитьУровень(УровниЛога.Отладка);
		Лог.Отладка("Установлен уровень логов ОТЛАДКА");
		
	КонецЕсли;
	
КонецПроцедуры

// Получает экземпляр класса загрузчика правил
//
// Параметры:
//   УчитыватьСозданиеНовогоЭкземпляра - Булево - Если Ложь,
//   то при отсутствии экземпляра класса, будет создан новый,
//   иначе - будет возвращено текущее значение
//
// Возвращаемое значение:
//   ЗагрузчикПравил, Неопределено - возвращает объект загрузчика правил или неопределенное значение
//
Функция ПолучитьЗагрузчикПравил(УчитыватьСозданиеНовогоЭкземпляра = Истина) Экспорт
	
	Если Не ЗначениеЗаполнено(ЗагрузчикПравил) И УчитыватьСозданиеНовогоЭкземпляра Тогда
		Лог.Информация("Используется 'Загрузчик правил'");
		ЗагрузчикПравил = Новый ЗагрузчикПравил;
		Возврат ЗагрузчикПравил;
	КонецЕсли;

	Возврат ЗагрузчикПравил;

КонецФункции

// Устанавливает режим записи ошибок правил в файл
// * Если "Истина" - ошибки правил будут записываться в файл, иначе - без записи в файл
//
// Параметры:
//   РежимЗаписиОшибокПравил - Булево - (по-умолчанию - Ложь)
//
Процедура УстановитьРежимЗаписиОшибокПравил(РежимЗаписиОшибокПравил = Ложь) Экспорт
	ЗаписьОшибокПравил = РежимЗаписиОшибокПравил;
	Если РежимЗаписиОшибокПравил Тогда
		Лог.Информация("Включен режим записи ошибок правил в файл");
	КонецЕсли;
КонецПроцедуры

// Возвращает значение режима записи ошибок правил в файл
//
// Возвращаемое значение:
//   Булево - Если, Истина - запись ошибок правил будет выполняться в файл
//
Функция ПолучитьРежимЗаписиОшибокПравил() Экспорт
	Возврат ЗаписьОшибокПравил;
КонецФункции

// Возвращает контекст параметров проверки
//
//  Возвращаемое значение:
//   Строка - контекст ошибок
//
Функция ПолучитьКонтекстПараметров() Экспорт
	
	Возврат КонтекстПараметров;

КонецФункции

// Устанавливает путь до файла содержащего настройки проверки.
//
// Параметры:
//   ПутьКФайлу - Строка - Путь к файлу настроек проверки
//
Процедура УстановитьКонтекстПараметров(Знач ПутьКФайлу) Экспорт

	Если ЗначениеЗаполнено(ПутьКФайлу) Тогда
		 КонтекстПараметров = ФС.ПолныйПуть(ПутьКФайлу);
		 Лог.Отладка("Установлен новый контекст параметров: %1", КонтекстПараметров);
	Иначе
		Если ЗначениеЗаполнено(КонтекстПараметров) Тогда
			Лог.Отладка("Очищен контекст параметров");
		КонецЕсли;
		КонтекстПараметров = "";
	КонецЕсли;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции


#КонецОбласти
