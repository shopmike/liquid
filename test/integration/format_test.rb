require 'test_helper'

class FormatTest < Minitest::Test
  include Liquid

  def test_string_only
    assert_template_format('foo', 'foo')
    assert_template_format('foo bar', 'foo bar')
  end

  def test_variable_only
    assert_template_format('{{ foo }}', '{{foo}}')
    assert_template_format('{{ foo.bar }}', '{{foo.bar}}')
    assert_template_format('{{ foo.hello }}', '{{ foo["hello"] }}')
    assert_template_format('{{ foo[hello] }}', '{{ foo[hello] }}')
    assert_template_format('{{ foo.bar.world }}', '{{ foo["bar"].world }}')
    assert_template_format('{{ foo }}{{ bar }}', '{{foo}}{{bar}}')
    assert_template_format(%({{ input | substitute: first_name: surname, last_name: 'doe' }}), %({{ input | substitute: first_name: surname, last_name: 'doe' }}))
    assert_template_format(%({{ input | substitute: hello, 'two', first_name: surname, last_name: 'doe' }}), %({{ input | substitute: hello, 'two', first_name: surname, last_name: 'doe' }}))
    assert_template_format(
      %({{ input | substitute: hello, 'two', first_name: surname, last_name: 'doe' | substitute: hello, 'two', first_name: surname, last_name: 'doe' }}),
      %({{ input | substitute: hello, 'two', first_name: surname, last_name: 'doe' | substitute: hello, 'two', first_name: surname, last_name: 'doe' }})
    )
  end

  def test_raises_error_when_no_format
    klass1 = Class.new(Tag) do
      def render(*)
        'hello'
      end

      def self.name
        'blabla'
      end
    end

    with_custom_tag('blabla', klass1) do
      assert_raises(FormatError) do
        Template.parse("{% blabla %}").format
      end
    end
  end
end
