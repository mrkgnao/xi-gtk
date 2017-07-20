// Copyright 2017 Elias Aebi
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

namespace Xi {

class Window: Gtk.ApplicationWindow {
	public CoreConnection core_connection { construct; get; }
	private Xi.Notebook notebook;

	public Window(Gtk.Application application, CoreConnection core_connection) {
		Object(application: application, core_connection: core_connection);
	}

	construct {
		set_default_size(600, 400);

		// actions
		var new_tab_action = new SimpleAction("new-tab", null);
		new_tab_action.activate.connect(() => {
			add_new_tab();
		});
		add_action(new_tab_action);
		var open_action = new SimpleAction("open", null);
		open_action.activate.connect(() => {
			var dialog = new Gtk.FileChooserDialog(null,
												   this, Gtk.FileChooserAction.OPEN,
												   "Cancel", Gtk.ResponseType.CANCEL,
												   "Open", Gtk.ResponseType.ACCEPT);
			dialog.select_multiple = true;
			if (dialog.run() == Gtk.ResponseType.ACCEPT) {
				foreach (var file in dialog.get_files()) {
					add_new_tab(file);
				}
			}
			dialog.destroy();
		});
		add_action(open_action);
		var save_action = new SimpleAction("save", null);
		save_action.activate.connect(() => {
			notebook.get_current_edit_view().save();
		});
		add_action(save_action);
		var save_as_action = new SimpleAction("save-as", null);
		save_as_action.activate.connect(() => {
			notebook.get_current_edit_view().save_as();
		});
		add_action(save_as_action);

		var header_bar = new Gtk.HeaderBar();
		header_bar.show_close_button = true;
		header_bar.title = "Xi";
		var new_button = new Gtk.Button.from_icon_name("document-new-symbolic", Gtk.IconSize.BUTTON);
		new_button.tooltip_text = "New File";
		new_button.action_name = "win.new-tab";
		header_bar.pack_start(new_button);
		var open_button = new Gtk.Button.from_icon_name("document-open-symbolic", Gtk.IconSize.BUTTON);
		open_button.tooltip_text = "Open File";
		open_button.action_name = "win.open";
		header_bar.pack_start(open_button);
		var save_button = new Gtk.Button.from_icon_name("document-save-symbolic", Gtk.IconSize.BUTTON);
		save_button.tooltip_text = "Save File";
		save_button.action_name = "win.save";
		header_bar.pack_end(save_button);
		set_titlebar(header_bar);

		notebook = new Xi.Notebook();
		add(notebook);
	}

	public void add_new_tab(File? file = null) {
		core_connection.send_new_view(file != null ? file.get_path() : null, (result) => {
			string view_id = result.get_string();
			this.notebook.add_edit_view(new EditView(view_id, file, core_connection));
		});
	}
}

}
