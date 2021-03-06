require 'spec_helper'
require 'pincers/backend/base'

describe Pincers::Core::RootContext do

  let!(:backend) do
    be = double('Pincers::Backend::Base')
    allow(be).to receive(:document)                   { 'not a real document' }
    allow(be).to receive(:document_root)              { ['root_element'] }
    allow(be).to receive(:document_url)               { 'the.page.url' }
    allow(be).to receive(:document_title)             { 'The page title' }
    allow(be).to receive(:fetch_cookies)              { [{ name: 'FakeCookie' }] }
    allow(be).to receive(:navigate_to)
    allow(be).to receive(:navigate_forward)
    allow(be).to receive(:navigate_back)
    allow(be).to receive(:refresh_document)
    allow(be).to receive(:search_by_css)              { |el, sel| ['child_element_1', 'child_element_2'] }
    allow(be).to receive(:search_by_xpath)            { |el, sel| ['child_element_1', 'child_element_2'] }
    allow(be).to receive(:extract_element_tag)        { |el| "#{el.upcase}-NAME" }
    allow(be).to receive(:extract_element_text)       { |el| "#{el} text" }
    allow(be).to receive(:extract_element_html)       { |el| "<div>#{el} html</div>" }
    allow(be).to receive(:extract_element_attribute)  { |el, attribute| "#{el} #{attribute}" }
    allow(be).to receive(:set_element_text)
    allow(be).to receive(:click_on_element)
    allow(be).to receive(:switch_to_frame)
    allow(be).to receive(:switch_to_top_frame)
    allow(be).to receive(:switch_to_parent_frame)

    be
  end

  let(:pincers) { Pincers::Core::RootContext.new backend }

  describe "url" do
    it "should return the current url" do
      expect(pincers.url).to eq('the.page.url')
    end
  end

  describe "title" do
    it "should return the current page title" do
      expect(pincers.title).to eq('The page title')
    end
  end

  describe "goto" do
    it "should call navigate_to and return self" do
      expect(pincers.goto 'foo.bar').to eq(pincers)
      expect(backend).to have_received(:navigate_to).with('foo.bar')
    end

    it "should call switch_to_frame with proper element if called with frame: context" do
      pincers.goto frame: pincers.css('#frame')
      expect(backend).to have_received(:switch_to_frame).with('child_element_1')
    end

    it "should call switch_to_frame with proper element if called with frame: selector" do
      pincers.goto frame: '#foo.bar'
      expect(backend).to have_received(:switch_to_frame).with('child_element_1')
    end

    it "should call switch_to_top_frame if called with frame: :top" do
      pincers.goto frame: :top
      expect(backend).to have_received(:switch_to_top_frame)
    end

    it "should call switch_to_parent_frame if called with frame: :parent" do
      pincers.goto frame: :parent
      expect(backend).to have_received(:switch_to_parent_frame)
    end

    it "should fail when called with invalid options" do
      expect { pincers.goto }.to raise_error
      expect { pincers.goto frame: :disneyland }.to raise_error
      expect { pincers.goto cuadro: 'cangrejo' }.to raise_error
    end

    it "when called on a frame element context it should call goto frame: context on the root context" do
      pincers.css('#frame').goto
      expect(backend).to have_received(:switch_to_frame).with('child_element_1')
    end
  end

  describe "back" do
    it "should call navigate_back and return self" do
      expect(pincers.back 'foo.bar').to eq(pincers)
      expect(backend).to have_received(:navigate_back).with('foo.bar')
    end
  end

  describe "forward" do
    it "should call navigate_forward and return self" do
      expect(pincers.forward 'foo.bar').to eq(pincers)
      expect(backend).to have_received(:navigate_forward).with('foo.bar')
    end
  end

  describe "classes" do
    it "should return every element class as an array" do
      expect(pincers.classes).to eq(['root_element', 'class'])
    end
  end

  describe "tag" do
    it "should return the downcased tag name from the first of matched elements" do
      expect(pincers.tag).to eq('root_element-name')
    end
  end

  describe "text" do
    it "should return the text from the first of matched elements" do
      expect(pincers.text).to eq('root_element text')
    end
  end

  describe "css" do
    it "should invoke the search_by_css method with the given selector for every context element" do
      childs = pincers.css('selector')
      expect(backend).to have_received(:search_by_css).exactly(1).times

      grandchilds = childs.css('selector')
      expect(backend).to have_received(:search_by_css).exactly(3).times

      expect(grandchilds.count).to eq(4)
    end
  end

  describe "to_html" do
    it "should return the html representation of the matched elements" do
      expect(pincers.to_html).to eq('<div>root_element html</div>')
    end
  end

  describe "set_text" do
    it "should map to backend's set_element_text" do
      pincers.set_text 'foo'
      expect(backend).to have_received(:set_element_text).with('root_element', 'foo')
    end
  end

  describe "click" do
    it "should map to backend's click_on_element" do
      pincers.click
      expect(backend).to have_received(:click_on_element).with('root_element')
    end
  end

  context "given a search result" do

    let(:search) { pincers.css('selector') }

    describe "is Enumerable" do
      it "should iterate over matching elements, wrapping each element in a new context" do
        expect(search.to_a.count).to eq(2)
        expect(search).to all ( be_a Pincers::Core::SearchContext )
      end
    end

    describe "[]" do

      it "should return the element in position N wrapped in search context if numeric index is given" do
        expect(search[1]).to be_a(Pincers::Core::SearchContext)
        expect(search[1].element!).to eq('child_element_2')
      end

      it "should return the attribute named N of the first element if string is given" do
        expect(search[:type]).to eq('child_element_1 type')
      end

    end

    describe "to_html" do
      it "should concatenate the html representation of all matched elements" do
        expect(search.to_html).to eq('<div>child_element_1 html</div><div>child_element_2 html</div>')
      end
    end

  end

end