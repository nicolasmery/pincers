require 'pincers/backend/base'

module Pincers::Backend

  class Webdriver < Base

    attr_reader :driver

    def initialize(_driver)
      super _driver
      @driver = _driver
    end

    def document_root
      [@driver]
    end

    def document_url
      @driver.current_url
    end

    def document_title
      @driver.title
    end

    def fetch_cookies
      @driver.manage.all_cookies
    end

    def navigate_to(_url)
      @driver.get _url
    end

    def navigate_forward(_steps)
      _steps.times { @driver.navigate.forward }
    end

    def navigate_back(_steps)
      _steps.times { @driver.navigate.back }
    end

    def refresh_document
      @driver.navigate.refresh
    end

    def search_by_css(_element, _selector)
      _element.find_elements css: _selector
    end

    def search_by_xpath(_element, _selector)
      _element.find_elements xpath: _selector
    end

    def extract_element_tag(_element)
      _element = ensure_element _element
      _element.tag_name
    end

    def extract_element_text(_element)
      _element = ensure_element _element
      _element.text
    end

    def extract_element_html(_element)
      return @driver.page_source if _element == @driver
      _element.attribute 'outerHTML'
    end

    def extract_element_attribute(_element, _name)
      _element = ensure_element _element
      _element[_name]
    end

    def set_element_text(_element, _value)
      _element = ensure_element _element
      _element.clear
      _element.send_keys _value
    end

    def click_on_element(_element)
      _element = ensure_element _element
      _element.click
    end

    def switch_to_frame(_element)
      @driver.switch_to.frame _element
    end

    def switch_to_top_frame
      @driver.switch_to.default_content
    end

    # wait contitions

    def check_present(_elements)
      _elements.length > 0
    end

    def check_not_present(_elements)
      _elements.length == 0
    end

    def check_visible(_elements)
      check_present(_elements) and _elements.first.displayed?
    end

    def check_enabled(_elements)
      check_visible(_elements) and _elements.first.enabled?
    end

    def check_not_visible(_elements)
      not _elements.any? { |e| e.displayed? }
    end

  private

    def ensure_element(_element)
      return @driver.find_element tag_name: 'html' if _element == @driver
      _element
    end

  end

end