require 'date'
require 'dbi'

class BookInfo 
  attr_accessor :title, :author, :pages, :publish_date
  def initialize(title, author, pages, publish_date)
    @title = title
    @author = author
    @pages = pages
    @publish_date = publish_date
  end
  
  def to_s
    "#{@title},#{@author},#{@pages},#{@publish_date}"
  end
  
  def toFormattedString(sep="\n")
    "書籍名：#{@title}#{sep}著者名：#{@author}#{sep}ページ数：#{@pages.to_s}#{sep}発刊日：#{@publish_date.to_s}#{sep}"
  end
end

class BookInfoManager
  def initialize(db_fname="books.db")
    @db_fname = db_fname
    
    @dbh = DBI.connect("DBI:SQLite3:#{@db_fname}")

    @dbh.do('create table if not exists bookinfos(TITLE VARCHAR(50), AUTHOR VARCHAR(50),PAGES INT, PUBLISH_DATE DATE)')
  
      puts 'bookinfosテーブルを作成完了'

    @dbh.disconnect
  
  end

  def addBookInfo
    @book_info = BookInfo.new("", "", 0, Date.new)
    print "書籍名："
    @book_info.title = gets.chomp
    print "著者名："
    @book_info.author = gets.chomp
    print "ページ数：" 
    @book_info.pages = gets.chomp.to_i
    print "発刊年："
    year = gets.chomp.to_i
    print "発刊月："
    month = gets.chomp.to_i
    print "発刊日："
    day = gets.chomp.to_i
    @book_info.publish_date = Date.new( year, month, day )
    
    @dbh = DBI.connect('DBI:SQLite3:books.db')
    @dbh.do("insert into bookinfos values('#{@book_info.title}','#{@book_info.author}','#{@book_info.pages}','#{@book_info.publish_date}')")
    @dbh.disconnect
  end
  
  def listAllBookInfos
    @dbh = DBI.connect('DBI:SQLite3:books.db')
    @dbh.select_all('select * from bookinfos') do |row|
      puts "#{row[0]}, #{row[1]}, #{row[2]}, #{row[3]}"
    end
    @dbh.disconnect
  end
  
  def delete
    listAllBookInfos
    print "削除する書籍名を入力してください(キャンセルする場合はエンターのみ)"
    title = gets.chomp
    if title != ""
    @dbh = DBI.connect('DBI:SQLite3:books.db')
    @dbh.do("delete from bookinfos where title='#{title}'")
    @dbh.disconnect
    end
  end
  
  def run
    while true
      #メニュー表示（puts）
      print "0.蔵書データの削除
1.蔵書データの登録
2.蔵書データの表示
9.終了
番号を選んでください(0,1,2,9):"
      #メニュー番号受付（gets.chomp）
      num = gets.chomp 
      #メニュー番号に応じた処理を実行する（case / when）
      case num
      when '0'
      #データの削除（delete）
        delete
      when '1'
      #登録処理（addBookInfo）
        addBookInfo
      when '2'
        #表示処理（listAllBookInfos）
        listAllBookInfos
      when '9'
        #終了（break）
        break
        #１番に戻る
      end
    end
  end
end

bim = BookInfoManager.new
bim.run