#!/usr/bin/env ruby

class Scrapper

  # Definition de la méthode get_townhall_email(townhall_url)
  # Recupération des URLs de chaque ville du Val d'Oise

    def get_townhall_email(townhall_url)
        page = Nokogiri::HTML(open(townhall_url)) 
        email_array = []
        email = page.xpath('//*[contains(text(), "@")]').text
        town = page.xpath('//*[contains(text(), "Adresse mairie de")]').text.split 
        email_array << {town[3] => email} 
        puts email_array
        return email_array
    end

  
  # Méthode permettant d'extraire toutes les urls de chaque ville du Val d'Oise 
  # Stockage d'url dans un array 

    def get_townhall_urls(dept_url)
      page = Nokogiri::HTML(open("http://annuaire-des-mairies.com/val-d-oise.html"))
      url_array = []
      urls = page.xpath('//*[@class="lientxt"]/@href') 
      urls.each do |url| 
      url = "http://annuaire-des-mairies.com/"+ url.text[1..-1] 
      url_array << url
    end
      return url_array
    end

  #Assemblage des infos
    def initialize(dept)
       @array=[]
       get_townhall_urls(dept).map{|i| @array << get_townhall_email(i)}
       return @array
    end
  
  #Enregistrer les emails dans json
    def save_as_JSON
       File.open("db/emails.json","w") do |f|
       f.write(@array.map{|i| Hash[i.each_pair.to_a]}.to_json)
    end
    end

#Enregistrer les emails dans google spreadsheet
  def save_as_spreadsheet
      session = GoogleDrive::Session.from_config("config.json")
      sp = session.spreadsheet_by_key("1hL7MdDOl9JqmuSuTkAeN3Q1w2CqCU3fU0aUHQkm3ldg").worksheets[0]
      sp[1, 1] = @array.first.keys[0]
      sp[1, 2] = @array.first.keys[1]
      @array.map.with_index{|hash,index|
        sp[index+2, 1] = hash['ville']
        sp[index+2, 2] = hash['email']
      }
      sp.save
  end  

#Enregistrer les emails dans csv
  def save_as_csv
      CSV.open("db/emails.csv", "wb") do |csv|
      csv << @array.first.keys
      @array.each do |hash|
      csv << hash.values
      end
    end
  end
end