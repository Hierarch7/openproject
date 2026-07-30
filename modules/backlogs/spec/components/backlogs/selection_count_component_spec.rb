# frozen_string_literal: true

#-- copyright
# OpenProject is an open source project management software.
# Copyright (C) the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

require "rails_helper"

RSpec.describe Backlogs::SelectionCountComponent, type: :component do
  subject(:rendered_component) { render_inline(described_class.new) && page }

  it "renders a count region wired to the sortable-lists root" do
    expect(rendered_component).to have_css('[data-sortable-lists-target="selectionCount"]', visible: :hidden)
  end

  it "starts hidden, because a count of nothing is noise" do
    expect(rendered_component).to have_css('[data-sortable-lists-target="selectionCount"][hidden]', visible: :hidden)
  end

  it "renders no count text server-side" do
    expect(rendered_component.find('[data-sortable-lists-target="selectionCount"]', visible: :hidden).text).to eq("")
  end

  it "renders the description every selected card points at" do
    expect(rendered_component)
      .to have_css("##{described_class::DESCRIPTION_ID}", text: I18n.t("js.backlogs.selection.card_state"),
                                                          visible: :hidden)
  end
end
