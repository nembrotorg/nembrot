Embiggen.configure do |config|
  config.timeout = 5
  config.redirects = 2
  config.shorteners += %w(t.co ow.ly po.st fw.to bit.ly qz.com fam.ag ift.tt 
    nyr.kr gu.com hbr.org buff.ly lgrd.co wapo.st shar.es tcat.tc slate.me 
    ifttt.com tinyurl.com)
end
