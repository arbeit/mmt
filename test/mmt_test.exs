defmodule MmtTest do
  @moduledoc """
  Tests pertaining to the functions in mmt.ex

  mmt is a simple utility that allows the automated sending of emails
  using a configuration file and a template for the email body. It was
  written in Elixir and used mainly on linux systems like Arch Linux
  and Ubuntu.
  Copyright (C) 2015-2016  Muharem Hrnjadovic <muharem@linux.com>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
  """
  use ExUnit.Case
  doctest Mmt


  test "prep_emails()" do
    config = """
      # config file with repeating keys (email addresses)
          # dangling comment
      [sender]
      rts@example.com=Frodo Baggins
      [recipients]
      abx.fgh@exact.ly=Éso Pita
      fheh@fphfdd.cc=Gulliver    Jöllo
      abx.fgh@exact.ly=   Charly      De Gaulle
      [attachments]
      abx.fgh@exact.ly=01
      fheh@fphfdd.cc=02
      abx.fgh@exact.ly=03
      """
    template = """
      Hello %FN% // %LN% // %EA%
      """
    expected = [
      {"abx.fgh@exact.ly", "Hello Charly // De Gaulle // abx.fgh@exact.ly\n"},
      {"fheh@fphfdd.cc", "Hello Gulliver // Jöllo // fheh@fphfdd.cc\n"}]
    config = Cfg.read_config(config)
    actual = Mmt.prep_emails(config, template)
    assert expected == actual
  end


  test "prep_headers(), nothing to do" do
    assert Mmt.prep_headers(%{"general" => %{}}) == []
  end


  test "prep_headers(), 'From:' header" do
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    expected = ["From: Frodo Baggins <mmt@chlo.cc>"]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers(), 'Cc:' header" do
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "Cc" => "jk@lm.no  ,       abc@def.ghi"}}
    expected = ["Cc: abc@def.ghi, jk@lm.no"]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers(), 'From:' and 'Cc:' header" do
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "sender-email" => "nno@cckd.cc",
                     "sender-name" => "Sam Lfhorf",
                     "Cc" => "jk@lm.no  ,       bc@def.ghi,   aa@bb.cc"}}
    expected = [
      "Cc: aa@bb.cc, bc@def.ghi, jk@lm.no", "From: Sam Lfhorf <nno@cckd.cc>"]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers(), 'Reply-To:' header" do
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "Reply-To" => "jk@lm.no"}}
    expected = ["Reply-To: jk@lm.no"]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers(), 'Reply-To:' header, multiple addresses" do
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "Reply-To" => "jk@lm.no 	,   	ab@kfd.cc"}}
    expected = ["Reply-To: ab@kfd.cc, jk@lm.no"]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers(), 'From:' and 'Reply-To:' header" do
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "sender-email" => "nno@cckd.cc",
                     "sender-name" => "Sam Lfhorf",
                     "Reply-To" => "aa@bb.cc"}}
    expected = ["From: Sam Lfhorf <nno@cckd.cc>", "Reply-To: aa@bb.cc"]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers() <mailx>, nothing to do" do
    assert Mmt.prep_headers(%{"general" => %{}}) == []
  end


  test "prep_headers() <mailx>, 'From:' header" do
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    expected = [["-r", "Frodo Baggins <mmt@chlo.cc>"]]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers() <mailx>, 'Cc:' header" do
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "Cc" => "jk@lm.no  ,       abc@def.ghi"}}
    expected = [["-c", "abc@def.ghi, jk@lm.no"]]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers() <mailx>, 'From:' and 'Cc:' header" do
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "sender-email" => "nno@cckd.cc",
                     "sender-name" => "Sam Lfhorf",
                     "Cc" => "jk@lm.no  ,       bc@def.ghi,   aa@bb.cc"}}
    expected = [
      ["-c", "aa@bb.cc, bc@def.ghi, jk@lm.no"],
      ["-r", "Sam Lfhorf <nno@cckd.cc>"]]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers() <mailx>, 'Reply-To:' header" do
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "Reply-To" => "jk@lm.no"}}
    expected = [["-S replyto=", "jk@lm.no"]]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers() <mailx>, 'Reply-To:' header, multiple addresses" do
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "Reply-To" => "jk@lm.no 	,   	ab@kfd.cc"}}
    expected = [["-S replyto=", "ab@kfd.cc, jk@lm.no"]]
    assert Mmt.prep_headers(config) == expected
  end


  test "prep_headers() <mailx>, 'From:' and 'Reply-To:' header" do
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "sender-email" => "nno@cckd.cc",
                     "sender-name" => "Sam Lfhorf",
                     "Reply-To" => "aa@bb.cc"}}
    expected = [
      ["-S replyto=", "aa@bb.cc"], ["-r", "Sam Lfhorf <nno@cckd.cc>"]]
    assert Mmt.prep_headers(config) == expected
  end


  test "construct_cmd() w/o attachments and headers" do
    path = "/tmp/mmt.kTuJU.eml"
    config = %{
      "general" => %{"mail-prog" => "gnu-mail"}}
    subj = "hello from mmt"
    addr = "r2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" r2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() w/o attachments" do
    path = "/tmp/mmt.kTuJU.eml"
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -a \"From: Frodo Baggins <mmt@chlo.cc>\" r2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() w/o attachments and with both headers" do
    path = "/tmp/mmt.kTuJU.eml"
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "Cc" => "x@y.zz  ,  a@bb.cc,   f@g.hh",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -a \"Cc: a@bb.cc, f@g.hh, x@y.zz\" -a \"From: Frodo Baggins <mmt@chlo.cc>\" r2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() w/o attachments and with Reply-To header" do
    path = "/tmp/mmt.kTuJX.eml"
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "Reply-To" => "x@y.zz  ",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2d2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -a \"From: Frodo Baggins <mmt@chlo.cc>\" -a \"Reply-To: x@y.zz\" r2d2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() w/o attachments and with Reply-To header, multi address" do
    path = "/tmp/mmt.kTuKX.eml"
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "Reply-To" => "x@y.zz  , 	add@kdhfo.co",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2d2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -a \"From: Frodo Baggins <mmt@chlo.cc>\" -a \"Reply-To: add@kdhfo.co, x@y.zz\" r2d2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() with encrypted attachments" do
    path = "/tmp/mmt.kTuJZ.eml"
    atp = "/tmp/atp"
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "encrypt-attachments" => true,
                     "attachment-path" => atp,
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"},
      "attachments" => %{"ab@example.com" => "aa.pdf",
                         "cd@gmail.com" => "bb.pdf"}}
    subj = "hello from mmt"
    addr = "cd@gmail.com"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -A #{atp}/bb.pdf.gpg -a \"From: Frodo Baggins <mmt@chlo.cc>\" cd@gmail.com"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() with clear text attachments" do
    path = "/tmp/mmt.kTuJU.eml"
    atp = "/tmp/atp"
    config = %{
      "general" => %{"mail-prog" => "gnu-mail",
                     "attachment-path" => atp,
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"},
      "attachments" => %{"ab@example.com" => "aa.pdf",
                         "cd@gmail.com" => "bb.pdf"}}
    subj = "hello from mmt"
    addr = "ab@example.com"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -A #{atp}/aa.pdf -a \"From: Frodo Baggins <mmt@chlo.cc>\" ab@example.com"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() <mailx> w/o attachments and headers" do
    path = "/tmp/mmt.kTuJU.eml"
    config = %{
      "general" => %{"mail-prog" => "mailx"}}
    subj = "hello from mmt"
    addr = "r2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" r2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() <mailx> w/o attachments" do
    path = "/tmp/mmt.kTuJU.eml"
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -r \"Frodo Baggins <mmt@chlo.cc>\" r2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() <mailx> w/o attachments and with both headers" do
    path = "/tmp/mmt.kTuJU.eml"
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "Cc" => "x@y.zz  ,  a@bb.cc,   f@g.hh",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -c \"a@bb.cc, f@g.hh, x@y.zz\" -r \"Frodo Baggins <mmt@chlo.cc>\" r2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() <mailx> w/o attachments and with Reply-To header" do
    path = "/tmp/mmt.kTuJX.eml"
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "Reply-To" => "x@y.zz  ",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2d2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -S replyto=\"x@y.zz\" -r \"Frodo Baggins <mmt@chlo.cc>\" r2d2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() <mailx> w/o attachments and with Reply-To header, multi address" do
    path = "/tmp/mmt.kTuKX.eml"
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "Reply-To" => "x@y.zz  , 	add@kdhfo.co",
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"}}
    subj = "hello from mmt"
    addr = "r2d2@ahfdo.cc"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -S replyto=\"add@kdhfo.co, x@y.zz\" -r \"Frodo Baggins <mmt@chlo.cc>\" r2d2@ahfdo.cc"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() <mailx> with encrypted attachments" do
    path = "/tmp/mmt.kTuJZ.eml"
    atp = "/tmp/atp"
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "encrypt-attachments" => true,
                     "attachment-path" => atp,
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"},
      "attachments" => %{"ab@example.com" => "aa.pdf",
                         "cd@gmail.com" => "bb.pdf"}}
    subj = "hello from mmt"
    addr = "cd@gmail.com"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -a #{atp}/bb.pdf.gpg -r \"Frodo Baggins <mmt@chlo.cc>\" cd@gmail.com"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "construct_cmd() <mailx> with clear text attachments" do
    path = "/tmp/mmt.kTuJU.eml"
    atp = "/tmp/atp"
    config = %{
      "general" => %{"mail-prog" => "mailx",
                     "attachment-path" => atp,
                     "sender-email" => "mmt@chlo.cc",
                     "sender-name" => "Frodo Baggins"},
      "attachments" => %{"ab@example.com" => "aa.pdf",
                         "cd@gmail.com" => "bb.pdf"}}
    subj = "hello from mmt"
    addr = "ab@example.com"
    mprog = config["general"]["mail-prog"]
    expected = "cat #{path} | #{mprog} -s \"hello from mmt\" -a #{atp}/aa.pdf -r \"Frodo Baggins <mmt@chlo.cc>\" ab@example.com"

    actual = Mmt.construct_cmd(path, config, subj, addr)
    assert to_char_list(expected) == actual
  end


  test "email address substitution works" do
    template = """
      Hello buddy,
      this is your email: %EA%%EA%.

      Thanks!
      """
    body = """
      Hello buddy,
      this is your email: 1@xy.com1@xy.com.

      Thanks!
      """
    actual = Mmt.prep_email({template, "1@xy.com", "Not Needed"})
    assert {"1@xy.com", body} == actual
  end


  test "first name substitution works" do
    template = """
      Hello %FN%,
      this is your email: %EA%%EA%.

      Thanks!
      """
    body = """
      Hello Goth,
      this is your email: 2@xy.com2@xy.com.

      Thanks!
      """
    actual = Mmt.prep_email({template, "2@xy.com", "Goth Mox"})
    assert {"2@xy.com", body} == actual
  end


  test "last name substitution works" do
    template = """
      Hello %FN% // %LN%,
      this is your email: %EA%%EA%.

      Thanks!
      """
    body = """
      Hello King // Kong,
      this is your email: 3@xy.com3@xy.com.

      Thanks!
      """
    actual = Mmt.prep_email({template, "3@xy.com", "King Kong"})
    assert {"3@xy.com", body} == actual
  end


  test "substitution works for single arbitrary datum" do
    template = """
      Hello %FN% // %LN%,
      this is your email: %EA%%EA%.

      %GREETING%
      """
    body = """
      Hello Mik // Mak,
      this is your email: 3@xy.com3@xy.com.

      Love :)
      """
    actual = Mmt.prep_email({template, "3@xy.com", "Mik Mak|GREETING:-Love :)"})
    assert {"3@xy.com", body} == actual
  end


  test "substitution works for arbitrary data" do
    template = """
      Hello %FN% // %LN%,
      this is your email: %EA%%EA%.

      %T1% | %T2% | %T3%
      """
    body = """
      Hello Ab // Cd,
      this is your email: 3@xy.com3@xy.com.

      A | B | C
      """
    actual = Mmt.prep_email({template, "3@xy.com", "Ab Cd|T1:-A|T2:-B|T3:-C"})
    assert {"3@xy.com", body} == actual
  end


  test "dry_run() works w/o attachments" do
    config = %{
      "recipients" => %{"jd@example.com" => "John    Doe    III",
                        "mm@gmail.com" => "Mickey     Mouse"}}
    body1 = """
      Hello Honky !! Tonk,
      this is your email: 11@xy.com11@xy.com.

      Thanks!
      """
    body2 = """
      Hola Mini ## Mouse,
      this is your email: 22@xy.com22@xy.com.

      Gracias
      """
    expected1 = """
      To: 11@xy.com
      Subject: Test 1

      Hello Honky !! Tonk,
      this is your email: 11@xy.com11@xy.com.

      Thanks!
      ---
      """
    expected2 = """
      To: 22@xy.com
      Subject: Test 1

      Hola Mini ## Mouse,
      this is your email: 22@xy.com22@xy.com.

      Gracias
      ---
      """
    expected = [expected1, expected2]
    actual = Mmt.do_dryrun(
      [{"11@xy.com", body1}, {"22@xy.com", body2}], "Test 1", config)
    assert expected == actual
  end


  test "dry_run() works with attachments" do
    config = %{
      "general" => %{"attachment-path" => "/whatever"},
      "recipients" => %{"11@xy.com" => "John    Doe    III",
                        "22@xy.com" => "Mickey     Mouse"},
      "attachments" => %{"11@xy.com" => "aa.pdf",
                         "22@xy.com" => "bb.pdf"}}
    body1 = """
      Hello Honky !! Tonk,
      this is your email: 11@xy.com11@xy.com.

      Thanks!
      """
    body2 = """
      Hola Mini ## Mouse,
      this is your email: 22@xy.com22@xy.com.

      Gracias
      """
    expected1 = """
      To: 11@xy.com
      Subject: Test 1

      Hello Honky !! Tonk,
      this is your email: 11@xy.com11@xy.com.

      Thanks!

      <</whatever/aa.pdf>>
      ---
      """
    expected2 = """
      To: 22@xy.com
      Subject: Test 1

      Hola Mini ## Mouse,
      this is your email: 22@xy.com22@xy.com.

      Gracias

      <</whatever/bb.pdf>>
      ---
      """
    expected = [expected1, expected2]
    actual = Mmt.do_dryrun(
      [{"11@xy.com", body1}, {"22@xy.com", body2}], "Test 1", config)
    assert expected == actual
  end


  test "dry_run() works with crpypted attachments" do
    config = %{
      "general" => %{"attachment-path" => "/whatever",
                     "encrypt-attachments" => true},
      "recipients" => %{"11@xy.com" => "John    Doe    III",
                        "22@xy.com" => "Mickey     Mouse"},
      "attachments" => %{"11@xy.com" => "aa.pdf",
                         "22@xy.com" => "bb.pdf"}}
    body1 = """
      Hello Honky !! Tonk,
      this is your email: 11@xy.com11@xy.com.

      Thanks!
      """
    body2 = """
      Hola Mini ## Mouse,
      this is your email: 22@xy.com22@xy.com.

      Gracias
      """
    expected1 = """
      To: 11@xy.com
      Subject: Test 1

      Hello Honky !! Tonk,
      this is your email: 11@xy.com11@xy.com.

      Thanks!

      <</whatever/aa.pdf.gpg>>
      ---
      """
    expected2 = """
      To: 22@xy.com
      Subject: Test 1

      Hola Mini ## Mouse,
      this is your email: 22@xy.com22@xy.com.

      Gracias

      <</whatever/bb.pdf.gpg>>
      ---
      """
    expected = [expected1, expected2]
    actual = Mmt.do_dryrun(
      [{"11@xy.com", body1}, {"22@xy.com", body2}], "Test 1", config)
    assert expected == actual
  end


  test "parse_name_data() with empty string" do
    actual = Mmt.parse_name_data("")
    assert actual == %{}
  end


  test "parse_name_data() with minimum data" do
    data = "   First    	Last		  "
    actual = Mmt.parse_name_data(data)
    assert actual == %{"FN" => "First", "LN" => "Last" }
  end


  test "parse_name_data() with minimum data plus middle names" do
    data = "   First  M1	  M2  M3  	Last		  "
    actual = Mmt.parse_name_data(data)
    assert actual == %{"FN" => "First", "LN" => "M1 M2 M3 Last" }
  end


  test "parse_name_data() with additional key/value pairs" do
    data = "   First  M1	  M2  M3  	Last |  	CN :-	111| PX:-DyHich5	  "
    expected = %{"FN" => "First", "LN" => "M1 M2 M3 Last",
                  "CN" => "111", "PX" => "DyHich5" }
    assert Mmt.parse_name_data(data) == expected
  end


  test "parse_name_data() with additional malformed key/value pairs" do
    data = "   First  M1	  M2  M3  	Last |  	CN %	111| PX:-DyHich5	  "
    assert_raise(RuntimeError, "Invalid config: CN %	111",
                 fn -> Mmt.parse_name_data(data) end)
  end


  test "parse_name_data() with additional key/value pairs that override FN" do
    data = "   First  M1	  M2  M3  	Last |  	CN :-	Timo| FN:-DyHich5  "
    expected = %{"FN" => "DyHich5", "LN" => "M1 M2 M3 Last", "CN" => "Timo" }
    assert Mmt.parse_name_data(data) == expected
  end


  test "parse_name_data() with additional key/value pairs that override LN" do
    data = "   Lucky  M1	  M2  M3  	Last |  LN :-	Merkle| FN:-dymNaus2  "
    expected = %{"FN" => "Lucky", "LN" => "Merkle", "FN" => "dymNaus2" }
    assert Mmt.parse_name_data(data) == expected
  end
end
