
if has ("gui_running")
    "убираем скроллбары
    set guioptions-=r
    set guioptions-=l
endif

" Если есть makefile - собираем makeом.
" Иначе используем gcc для текущего файла.
if filereadable("Makefile")
    set makeprg=make
else
    set makeprg=gcc\ -Wall\ -o\ %<\ %
endif


"taglist config
let Tlist_Ctags_Cmd = "/usr/bin/ctags"
let Tlist_WinWidth = 50
map <F4> :TlistToggle<cr>

"ctags creates
map <F8> :!/usr/bin/ctags -R --c++-kinds=+p --fields=+iaS --extra=+q .<CR>


" Проверка требований, если нет утилиты sdcv то не включаем плагин
if !executable('sdcv')
    finish
endif

" Фукнция для перевода слова
" На входе слово для перевода, на выходе — перевод слова,
" который выдаёт sdcv
fun! Translate(word)
    let word = system('sdcv -n ' . a:word)
    return word
endfun

" Функция для открытия окна с переводом слова
" На входе слово для перевода, на выходе ничего,
" создаёт новое окно с переводом данного слова.
fun! WinTranslate(word)
    " Получение перевода, см. функцию выше
    let word = Translate(a:word)

    " Проверка, есть ли перевод.
    " С пустой строкой всё ясно, оператор =~# это поиск
    " по регулярке с учётом регистра
    " (мнемоника: =(равно)~(регулярка)#(учитывать регистр))
    "
    " У меня в русской локали LC_ALL=ru_RU.UTF-8
    " sdcv выдаёт "Ничего похожего на &lt;слово&gt;",
    " если словно не найдено.
    if word == '' || word =~# 'Ничего похожего на'
        echoerr "No translation found!"
        return
    endif

    " Ок, перевод есть, он в переменной word
    " Ниже все команды по настройке окна с переводом
    " заглушены командой silent, запрещающей всякий вывод от команд.

    silent new " Создаём новое окно

    " Специально для dr_magnus, у меня работает без этой строчки.
    " Явно разрешить модификацию окна с переводом.
    silent setl modifiable

    silent put =word " Вставляем перевод в это окно
    " Далее командой file устанавливаем красивое имя окна
    " "Translation for &lt;слово&gt;"
    silent exec 'file "Translation for '.a:word.'"'

    " Последний штрих, установка локальных параметров окна:
    " nomodified - притворимся, что мы его не меняли, чтобы вим не ругался
    " на несохранённые данным при закрытии окна,
    " nomodifiable - запретим все изменения в окне, ибо нефиг,
    " filetype=sdviv - нужно для отличия окна с переводом от других,
    " так что можно на него повесить специфичные автокоманды или подсветку
    " синтаксиса.
    silent setl nomodified nomodifiable filetype=sdviv
    
    " Переходим на первую строку в окне
    silent 1
endfun

" Настройка горячей клавишы, expand('<cword>') выдаёт текущее слово под
" курсором, можно также использовать <сWORD> для получения СЛОВА под курсором.
" Мнемника: c(urrent) word.
map <leader>t :call WinTranslate(expand('<cword>'))<cr>
