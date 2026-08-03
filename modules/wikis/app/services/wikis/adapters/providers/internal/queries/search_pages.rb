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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
#++

module Wikis
  module Adapters
    module Providers
      module Internal
        module Queries
          class SearchPages < BaseQuery
            MAXIMUM_RESULTS = 50

            def call(input_data:, auth_strategy:)
              success(
                WikiPage.visible(auth_strategy.user)
                        .where(id: matching_page_ids(input_data.query))
                        .limit(MAXIMUM_RESULTS)
                        .map { PageHierarchy.wiki_page_to_page_hierarchy(it, provider:) }
              )
            end

            private

            def matching_page_ids(query)
              WikiPage
                .with_recursive(
                  matching_pages: [
                    WikiPage.where("title ILIKE ?", "%#{query}%").select(:id),
                    WikiPage.select("wiki_pages.id")
                            .joins("INNER JOIN matching_pages ON wiki_pages.parent_id = matching_pages.id")
                  ]
                )
                .from("matching_pages")
                .select("matching_pages.id")
            end
          end
        end
      end
    end
  end
end
