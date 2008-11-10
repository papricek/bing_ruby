require 'singleton'
require 'white_list_helper'
# Singleton to be called in wrapper module
class TextHelperSingleton
  include Singleton
  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::TextHelper
  include WhiteListHelper
end

module BingRuby
  module String
    ##############################################################################
    #BingRuby methods
    ##############################################################################
    def remove_diacritics
      self.downcase.chars.normalize(:kd).to_s.gsub(/[^\x00-\x7F]/, '').downcase
    end
    
    def remove_diacritics_cs
      self.chars.normalize(:kd).to_s.gsub(/[^\x00-\x7F]/, '')
    end    
    
    def to_url
      self.remove_diacritics.gsub(/\s/, '-').gsub(/[^0-9a-z-]/, '')
    end
    
    def to_safe_filename
      self.remove_diacritics.gsub(/\s/, '-').gsub(/[^0-9a-z-\.]/, '')
    end
    
    def remove_nbsp
      self.gsub(/\&nbsp\;/," ")
    end
    
    def truncate_words(length = 5, end_string = ' …')
      words = self.split()
      words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
    end
    
    def app_space
      self.insert(-1, ' ') 
    end
    
    def prep_space
      self.insert(0, ' ') 
    end
    
    def decode_uri
      URI.escape(self)
    end
    
    def encode_uri
      URI.unescape(self)
    end
    
    def strip_special_objects
      self.gsub(/\*(graf|sloupcovy_graf|kolacovy_graf|fotogalerie|mapa|video_youtube|obrazek_vlevo|obrazek_vpravo|obrazek_stred)\*(.+?)\*(.+?)\*/m, "").gsub(/\*ramecek\*/, "")
    end
    
    def html_to_latex
      nahrady = [] << [/<\/p>/, " \\newline \n "] << [/<p>/, " "] << [/<\/div>/, " \\newline \n "] << [/<br \/>/, " \\newline \n "]
      nahrady << [/<\/li>/,""] << [/<li>/," \\item "]
      nahrady << [/<\/ul>/," \\end\{itemize\} "] << [/<ul>/," \\begin\{itemize\} "] 
      nahrady << [/<\/ol>/," \\end\{enumerate\} "] << [/<ol>/," \\begin\{enumerate\} "]
      nahrady << [/<h2>/," \\section\*\{ "] << [/<\/h2>/," \} "]
      nahrady << [/<h3>/," \\subsection\*\{ "] << [/<\/h3>/," \} "]
      nahrady << [/<h4>/," \\subsubsection\*\{ "] << [/<\/h4>/," \} "]
      nahrady << [/<h5>/," \\subsubsection\*\{ "] << [/<\/h5>/," \} "]
      nahrady << [/<em>/," \\textit\{ "] << [/<\/em>/," \} "]
      nahrady << [/<i>/," \\textit\{ "] << [/<\/i>/," \} "]
      nahrady << [/<strong>/," \\textbf\{ "] << [/<\/strong>/," \} "]
      nahrady << [/<b>/," \\textbf\{ "] << [/<\/b>/," \} "]
      nahrady << [/160\;/," "] << [/%/,"\\%"] << [/\#/,"\\#"] << [/\$/,"\\$"] << [/\_/,"\\_"]
      nahrady.each do |pattern, replacement|
        self.gsub!(pattern, replacement)
      end
      self.strip_tags.strip_special_objects
    end
    
    def html_to_rtf
      nahrady = [] << [/<\/p>/, " }\n "] << [/<p>/, "{\\par\\pard\\fs24 "] << [/<\/div>/, " \\line \n "] << [/<br \/>/, " \\line \n "]
      nahrady << [/<li>(.+?)<\/li>/," {\\par\\pard \\bullet   \\1 \\par} "]
      nahrady << [/<a(.+?)href="http:\/\/(.+?)">(.+?)<\/a>/, "{\\field{\\*\\fldinst{HYPERLINK \"http:\/\/\\2\"}}{\fldrslt{\\ul \\3 }}}"] << [/<a(.+?)href="(.+?)">(.+?)<\/a>/, "{\\ul \\3 }"]
      nahrady << [/<em>/,"\{\\i "] << [/<\/em>/,"\}"]
      nahrady << [/<i>/,"\{\\i "] << [/<\/i>/,"\}"]
      nahrady << [/<strong>/,"\{\\b "] << [/<\/strong>/,"\}"]
      nahrady << [/<b>/,"\{\\b "] << [/<\/b>/,"\}"]
      nahrady << [/<h1>/,"\{\\par\\pard\\fs50 "] << [/<\/h1>/,"\} \\line \n"]
      nahrady << [/<h2>/,"\{\\par\\pard\\fs42 "] << [/<\/h2>/,"\}"]
      nahrady << [/<h3>/,"\{\\par\\pard\\fs36\\i "] << [/<\/h3>/,"\}"]
      nahrady << [/<h4>/,"\{\\par\\pard\\fs24\\b "] << [/<\/h4>/,"\}"]
      nahrady << [/<h5>/,"\{\\par\\pard\\fs24\\b "] << [/<\/h5>/,"\}"]
      nahrady << [/&#160\;/," "]
      
      nahrady.each do |pattern, replacement|
        self.gsub!(pattern, replacement)
      end
      Iconv.iconv("windows-1250", "utf-8", self.strip_tags.strip_special_objects)
    end
  
    ##############################################################################
    #TextHelper and SanitizeHelper methods
    ##############################################################################
    def auto_link(link = :all, href_options = {}, &block)
      TextHelperSingleton.instance.auto_link(self, link, href_options, &block)
    end

    def excerpt(phrase, radius = 100, excerpt_string = "…")
      TextHelperSingleton.instance.excerpt(self, phrase, radius, excerpt_string)
    end

    def highlight(phrase, highlighter = '<strong class="highlight">\1</strong>')
      TextHelperSingleton.instance.highlight(self, phrase, highlighter)
    end
    
    def sanitize
      TextHelperSingleton.instance.sanitize(self)
    end
        
    def strip_tags
      TextHelperSingleton.instance.strip_tags(self)
    end
    
    def truncate(length = 30, truncate_string = "…")
      TextHelperSingleton.instance.truncate(self, length, truncate_string)
    end

    def word_wrap(line_width = 80)
      TextHelperSingleton.instance.word_wrap(self, line_width)
    end
    
    def white_list(&block)
      TextHelperSingleton.instance.white_list(self, &block)
    end
  end
  

  
  
end
