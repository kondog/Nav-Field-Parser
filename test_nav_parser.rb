# encoding: utf-8
require "test/unit"
require "./nav_parser.rb"
require "strscan"

class TC_NAV_P < Test::Unit::TestCase
  def setup
    @nav = NavParser.new
  end

  def test_parse_id
    assert_equal(  '1', @nav.parse_id( ' 1   ;' ))
  end

  def test_parse_name
    assert_equal(  'Package Code', @nav.parse_name( 'Package Code        ;') )
  end

  def test_parse_type
    assert_equal('Code20', @nav.parse_type( 'Code20        ;'))
  end

  def test_parse_caption_1_Langage
    assert_equal( 'CaptionML=ENU=Package Code', @nav.parse_caption(<<'EOS'))
                                               CaptionML=ENU=Package Code }
EOS
  end


  def test_parse_caption_1_Langage2
    assert_equal( 'CaptionML=ENU=Package Code', @nav.parse_caption(<<'EOS'))
                                               CaptionML=ENU=Package Code ;
EOS
  end

  def test_parse_caption_2_Langage
    assert_equal( 'CaptionML=[ENU=Package Code;JPN=あああ]', @nav.parse_caption(<<'EOS'))
                                               CaptionML=[ENU=Package Code;
                                                         JPN=あああ] };
EOS
  end

  def test_parse_caption_end_with_semicolon
    assert_equal( 'CaptionML=[ENU=Package Code;JPN=あああ]', @nav.parse_caption(<<'EOS'))
                                               CaptionML=[ENU=Package Code;
                                                         JPN=あああ] ;
EOS
  end

  def test_each_fields_parse
    @nav.parse_each_fields(<<'EOS')
{ 1   ;   ;Package Code        ;Code20        ;TableRelation="Config. Package";
                                               CaptionML=[ENU=Package Code;
                                                          JPN=あああ] }
EOS
    assert_equal( 
                 {:ID      => '1',
                  :Enable  => '',
                  :Name    => 'Package Code',
                  :Type    => 'Code20', 
                  :Caption => 'CaptionML=[ENU=Package Code;JPN=あああ]'
                 }, 
                @nav.fields[0] 
                )
  end

  def test_fields_parse
    @nav.parse_fields(<<'EOS')
    { 1   ;   ;Package Code        ;Code20        ;TableRelation="Config. Package";
                                                   CaptionML=[ENU=Package Code;
                                                              JPN=パッケージコード] }
    { 2   ;   ;Table ID            ;Integer       ;TableRelation=Object.ID WHERE (Type=CONST(Table));
                                                   OnValidate=BEGIN
                                                                IF ConfigMgt.IsSystemTable("Table ID") THEN
                                                                  ERROR(Text001,"Table ID");

                                                                IF "Table ID" <> xRec."Table ID" THEN
                                                                  "Page ID" := ConfigMgt.FindPage("Table ID");
                                                              END;

                                                   OnLookup=BEGIN
                                                              ConfigValidateMgt.LookupTable("Table ID");
                                                              IF "Table ID" <> 0 THEN
                                                                VALIDATE("Table ID");
                                                            END;

                                                   CaptionML=[ENU=Table ID;
                                                              JPN=テーブルID];
                                                   NotBlank=Yes }
    { 3   ;   ;Table Name          ;Text250       ;FieldClass=FlowField;
                                                   CalcFormula=Lookup(AllObjWithCaption."Object Name" WHERE (Object Type=CONST(Table),
                                                                                                             Object ID=FIELD(Table ID)));
                                                   CaptionML=[ENU=Table Name;
                                                              JPN=テーブル名];
                                                   Editable=No }
EOS
    assert_equal( 
                 {:ID      => '1',
                  :Enable  => '',
                  :Name    => 'Package Code',
                  :Type    => 'Code20', 
                  :Caption => 'CaptionML=[ENU=Package Code;JPN=パッケージコード]'
                 }, 
                @nav.fields[0] 
                )
    assert_equal( 
                 {:ID      => '2',
                  :Enable  => '',
                  :Name    => 'Table ID',
                  :Type    => 'Integer', 
                  :Caption => 'CaptionML=[ENU=Table ID;JPN=テーブルID]'
                 }, 
                @nav.fields[1] 
                )
    assert_equal( 
                 {:ID      => '3',
                  :Enable  => '',
                  :Name    => 'Table Name',
                  :Type    => 'Text250', 
                  :Caption => 'CaptionML=[ENU=Table Name;JPN=テーブル名]'
                 }, 
                @nav.fields[2] 
                )
  end

  def test_parse_file_data
    assert_equal( <<'INPUT1'[0..-2], @nav.parse_file_data(<<'EOS')
{ 1   ;   ;Package Code        ;Code20        ;TableRelation="Config. Package";
                                                   CaptionML=ENU=Package Code }
  }
  KEYS
INPUT1
OBJECT Table 8613 Config. Package Table
{
  OBJECT-PROPERTIES
  {
    Version List=NAVW17.00,S-003;
  }
  PROPERTIES
  {
    CaptionML=ENU=Config. Package Table;
  }
  FIELDS
  {
    { 1   ;   ;Package Code        ;Code20        ;TableRelation="Config. Package";
                                                   CaptionML=ENU=Package Code }
  }
  KEYS
  {
  }
  FIELDGROUPS
  {
  }
  CODE
  {
  }
}
EOS
                )
  end
end
