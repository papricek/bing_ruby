require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))

class BingRubyTest < Test::Unit::TestCase
  
  def setup
    @letters = "aábcčdďeěéfghchiíjklmnňoópqrřsštťuúůvwxyýzžAÁBCČDĎEĚÉFGHCHIÍJKLMNŇOÓPQRŘSŠTŤUÚŮVWXYÝZŽśźŕáââäĺćçčéęëěíîďđńňóôőö×řůúűüýţŚŹŔÁÂÂÄĹĆÇČÉĘËĚÍÎĎĐŃŇÓÔŐÖ×ŘŮÚŰÜÝŢßĄŞŻąşĽľż"
    @letters_without_diacritics = "aabccddeeefghchiijklmnnoopqrrssttuuuvwxyyzzAABCCDDEEEFGHCHIIJKLMNNOOPQRRSSTTUUUVWXYYZZszraaaalccceeeeiidnnooooruuuuytSZRAAAALCCCEEEEIIDNNOOOORUUUUYTASZasLlz"
    @letters_without_diacritics_downcased = @letters_without_diacritics.downcase
    @numbers = "0123456789"
    @symbols = " \"!\#$%&'()*+,-./:;<=>?@[\]^_`{|}~‚„†‡‰‘’“”•–—™› ˇ˘Ł¤¦§¨©¬«¬­®°±˛ł´µ¶·¸»˝˙…"
    @text = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. In magna erat, convallis ac, viverra nec, pharetra tempor, diam. Duis nisl. Proin interdum luctus sapien. Duis dignissim accumsan risus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Nunc iaculis rutrum nibh. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Etiam faucibus sapien et tellus. Cras massa. Quisque gravida tortor vel velit placerat congue. Proin eu nisl. Aliquam imperdiet. Vestibulum a pede. Fusce lorem. Nam at mi. Etiam metus. Aenean et lacus. Sed sagittis adipiscing nulla. Nulla metus massa, tincidunt ac, sagittis varius, vulputate id, nulla."
    @html = "<h3 class=\"title\">*ramecek**fotogalerie*<a href=\"/?q=design-patterns-a-singleton-in-ruby#comment-588\" class=\"active\">Showoff</a></h3>*fotogalerie*	<div class=\"submitted\">Submitted by <a href=\"/?q=user/keith-casey\" title=\"View user profile.\">Keith Casey on Thu, 2006-01-12 08:54.</div>"
    @html_short = "<h3 class='title'><a href='/?q=d#com588\' class=\"active\">Showoff</a></h3><script type='text/javascript'></script>"
  end
  
  def test_remove_diacritics
    assert_equal @letters.remove_diacritics, @letters_without_diacritics_downcased
  end
  
  def test_remove_diacritics_cs
    assert_equal @letters.remove_diacritics_cs, @letters_without_diacritics
  end

  def test_to_url
    assert_equal @numbers.to_url, @numbers
    assert_equal @symbols.to_url, "--tm--------"
  end
  
  def test_to_safe_filename
    assert_equal @symbols.to_safe_filename, "--.tm--------..."
  end
  
  def test_remove_nbsp
    assert_equal "&nbsppbnbpsp&nbsp;&nsbp;&nbsp;".remove_nbsp, "&nbsppbnbpsp &nsbp; "
  end
  
  def test_truncate_words
    assert_equal @text.truncate_words, "Lorem ipsum dolor sit amet, …"
  end
  
  def test_decode_undecode_uri
    decoded = URI.escape(@letters)
    assert_equal @letters.decode_uri, decoded
    assert_equal decoded.encode_uri, URI.unescape(decoded)
  end
  
  def test_app_space
    assert_equal "Lorem ipsum dolor sit amet".app_space, "Lorem ipsum dolor sit amet "
  end
  
  def test_prep_space
    assert_equal "Lorem ipsum dolor sit amet".prep_space, " Lorem ipsum dolor sit amet"
  end
  
  def test_strip_tags
    assert_equal @html.strip_tags, "*ramecek**fotogalerie*Showoff*fotogalerie*\tSubmitted by Keith Casey on Thu, 2006-01-12 08:54."
  end
  
  def test_strip_special_objects
    assert_equal @html.strip_tags.strip_special_objects, "\tSubmitted by Keith Casey on Thu, 2006-01-12 08:54."
  end
  
  def test_html_to_latex
    assert_equal "<p>Text</p></div><br />".html_to_latex, " Text \\newline \n  \\newline \n  \\newline \n "
    assert_equal "<ul><li></li></ul><ol><li></li></ol>".html_to_latex, " \\begin{itemize}  \\item  \\end{itemize}  \\begin{enumerate}  \\item  \\end{enumerate} "  
    assert_equal "<h2><h3><h4><h5>Nadpis</h5></h4></h3></h2>".html_to_latex, " \\section*{  \\subsection*{  \\subsubsection*{  \\subsubsection*{ Nadpis }  }  }  } "
    assert_equal "<em><i><strong><b>160;%$#_</em></i></strong></b>".html_to_latex, " \\textit{  \\textit{  \\textbf{  \\textbf{  \\%\\$\\#\\_ }  }  }  } "
  end
  
  def test_html_to_rtf
    assert_equal "<p>Text</p></div><br />".html_to_rtf, Iconv.iconv("windows-1250", "utf-8", "{\\par\\pard\\fs24 Text }\n  \\line \n  \\line \n ")
    assert_equal "<li>Odrazka</li>".html_to_rtf, Iconv.iconv("windows-1250", "utf-8", " {\\par\\pard \\bullet   Odrazka \\par} ")
    assert_equal "<h1><h2><h3><h4><h5>Nadpis</h5></h4></h3></h2></h1>".html_to_rtf, Iconv.iconv("windows-1250", "utf-8", "{\\par\\pard\\fs50 {\\par\\pard\\fs42 {\\par\\pard\\fs36\\i {\\par\\pard\\fs24\\b {\\par\\pard\\fs24\\b Nadpis}}}}} \\line \n")
    assert_equal "<em><i><strong><b>&#160;%$#_</em></i></strong></b>".html_to_rtf, Iconv.iconv("windows-1250", "utf-8","{\\i {\\i {\\b {\\b  %$#_}}}}")
  end
  
  def test_auto_link
    assert_equal "Visit http://www.loudthinking.com/ or e-mail david@loudthinking.com".auto_link(:email_addresses), "Visit http://www.loudthinking.com/ or e-mail <a href=\"mailto:david@loudthinking.com\">david@loudthinking.com</a>"
  end
  
  def test_highlight
    assert_equal 'You searched for: rails'.highlight('rails'), "You searched for: <strong class=\"highlight\">rails</strong>"
  end
  
  def test_excerpt
    assert_equal 'This is an example'.excerpt('an', 5), "…s is an exam…"
  end
  
  def test_sanitize
    assert_equal @html_short.sanitize, "<h3 class=\"title\"><a href=\"/?q=d#com588\" class=\"active\">Showoff</a></h3>"
  end
  
  def test_truncate
    assert_equal "Once upon a time in a world far far away".truncate(14), "Once upon a t…"  
  end
  
  def test_word_wrap
    assert_equal 'Once upon a time'.word_wrap(4), "Once\nupon\na\ntime"  
  end
  

  
  
end
