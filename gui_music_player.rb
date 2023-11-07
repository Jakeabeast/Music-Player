require 'rubygems'
require 'gosu'

TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, UI, ICON, TXT = *0..3
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Classic', 'Jazz', 'Rock']

class ArtWork
	attr_accessor :image
	def initialize (file)
		@image = Gosu::Image.new(file)
	end
end

# Put in your code here to load albums and tracks
class Album
# NB: you will need to add tracks to the following and the initialize()
	attr_accessor :title, :artist, :genre, :tracks, :art

# complete the missing code:
	def initialize (title, artist, genre, tracks, art)
		# insert lines here
		@title = title
		@artist = artist
		@genre = genre
		@tracks = tracks
		@art = ArtWork.new(art)
	end
end

class Track
	attr_accessor :name, :location

	def initialize (name, location)
		@name = name
		@location = location
	end
end

class MusicPlayerMain < Gosu::Window
	GAP = 20
	ART_SIZE = 270
	HIGHLIGHT = GAP/2
	SIDE_MENU = 700 + GAP
	MAX_SONGS_PER_ALBUM = 16

	def initialize
	    super 1100, 600
	    self.caption = "Music Player"

		@sections = 0
		@albums = Array.new()
		read_albums("albums.txt")
		@album_slot = nil
		@selected_song_track = nil
		@currently_playing = false

		@font = Gosu::Font.new(30)
		@track_font = Gosu::Font.new(20)
		@arrow = Gosu::Image.new("images/arrow.png")
		@pause = Gosu::Image.new("images/pause.png")
		@play = Gosu::Image.new("images/play.png")

		#print_albums(@album)
		# Reads in an array of albums from a file and then prints all the albums in the
		# array to the terminal
	end

	# Draws the album images and the track list for the selected album

	def draw
		draw_background()

		if(@album_slot != nil)
			draw_selected_slot()
			display_album_details()
		end

		draw_all_album_slots()
		draw_all_albums()
		draw_buttons()
	end

	# Draw a coloured background using TOP_COLOR and BOTTOM_COLOR
	def draw_background
		draw_quad(0,0,TOP_COLOR, 1100,0,TOP_COLOR, 0,600,BOTTOM_COLOR, 1100,600,BOTTOM_COLOR, ZOrder::BACKGROUND)
		draw_quad(SIDE_MENU, GAP, Gosu::Color::GRAY, 2000, GAP, Gosu::Color::GRAY, SIDE_MENU, 600 - GAP, Gosu::Color::GRAY, 2000, 600 - GAP, Gosu::Color::GRAY, ZOrder::BACKGROUND)
	end

	def draw_all_album_slots
		draw_album_slot(GAP, GAP)
		draw_album_slot(GAP*2 + ART_SIZE, GAP)
		draw_album_slot(GAP, GAP*2 + ART_SIZE)
		draw_album_slot(GAP*2 + ART_SIZE, GAP*2 + ART_SIZE)
	end

	def draw_album_slot(x, y)
		draw_line(x, y, Gosu::Color::BLACK, x + ART_SIZE, y, Gosu::Color::BLACK, ZOrder::UI)
		draw_line(x + ART_SIZE, y, Gosu::Color::BLACK, x + ART_SIZE, y + ART_SIZE, Gosu::Color::BLACK, ZOrder::UI )
		draw_line(x + ART_SIZE, y + ART_SIZE, Gosu::Color::BLACK, x, y + ART_SIZE, Gosu::Color::BLACK, ZOrder::UI )
		draw_line(x, y + ART_SIZE, Gosu::Color::BLACK, x, y, Gosu::Color::BLACK, ZOrder::UI)
	end
	# Not used? Everything depends on mouse actions.

	def draw_buttons()
		#up and down
		@arrow.draw_rot(GAP*3+ART_SIZE*2, GAP, ZOrder::ICON, 0, 0, 0)
		@arrow.draw_rot(GAP*3+ART_SIZE*2, GAP*2+ART_SIZE*2-100, ZOrder::ICON, 180, 1, 1)

		#play and pause
		if (@currently_playing)
			@pause.draw_rot(GAP*3+ART_SIZE*2, GAP+ART_SIZE-50, ZOrder::ICON, 0, 0, 0)
		else
			@play.draw_rot(GAP*3+ART_SIZE*2, GAP+ART_SIZE-50, ZOrder::ICON, 0, 0, 0)
		end
	end

	def needs_cursor?; true; end

	def button_down(id)
		case id
		when Gosu::MsLeft
			slot_clicked()
			arrow_clicked()
			track_clicked()
			play_pause_clicked()
		end
	end

	# Draws the artwork on the screen for all the albums
	def draw_all_albums()
		album_idx = 2*@sections
		slot_idx = 1
		while (album_idx < @albums.length && slot_idx <= 4)
			draw_album(@albums[album_idx].art.image, slot_idx)
			slot_idx += 1
			album_idx += 1
		end
	end

	def draw_album(image, slot = nil)
		case slot
		when 1
			image.draw(GAP, GAP)
		when 2
			image.draw(GAP*2+ART_SIZE, GAP)
		when 3
			image.draw(GAP, GAP*2+ART_SIZE)
		when 4
			image.draw(GAP*2+ART_SIZE, GAP*2+ART_SIZE)
		when nil
			image.draw(SIDE_MENU, 0 + GAP, ZOrder::ICON, 0.5, 0.5)
		end
	end

	def draw_selected_slot()
		#rule for deciding which box to highlight
		equ = @album_slot/2.ceil
		#if true, slot is in relative screen slot 1, or slot 2
		if(equ == @sections)
			#top left (1)
			if(@album_slot%2 == 0)
				draw_rect(GAP-HIGHLIGHT, GAP-HIGHLIGHT, ART_SIZE+HIGHLIGHT*2, ART_SIZE+HIGHLIGHT*2, Gosu::Color::BLACK, 0)
			#top right (2)
			else
				draw_rect(GAP*2+ART_SIZE-HIGHLIGHT, GAP-HIGHLIGHT, ART_SIZE+HIGHLIGHT*2, ART_SIZE+HIGHLIGHT*2, Gosu::Color::BLACK, 0)
			end
		#if true, slot is in relative screen slot 3, or slot 4
		elsif(equ-1 == @sections)
			#bottom left (3)
			if(@album_slot%2 == 0)
				draw_rect(GAP-HIGHLIGHT, GAP*2+ART_SIZE-HIGHLIGHT, ART_SIZE+HIGHLIGHT*2, ART_SIZE+HIGHLIGHT*2, Gosu::Color::BLACK, 0)
			#bottom right (4)
			else
				draw_rect(GAP*2+ART_SIZE-HIGHLIGHT, GAP*2+ART_SIZE-HIGHLIGHT, ART_SIZE+HIGHLIGHT*2, ART_SIZE+HIGHLIGHT*2, Gosu::Color::BLACK, 0)
			end
		end
	end

	def display_album_details()
		current_album = @albums[@album_slot]
		if (current_album == nil) then return end
		draw_album(current_album.art.image)

		@font.draw_text(current_album.title, 860, 40, 1)
		@font.draw_text(current_album.artist, 860, 70, 1)
		@font.draw_text(GENRE_NAMES[current_album.genre], 860, 100, 1)

		display_tracks(current_album)

	end

	def slot_clicked()
		if(area_clicked(GAP, GAP, ART_SIZE, ART_SIZE))
			clicked_slot = @sections*2 + 0
		elsif(area_clicked(GAP*2+ART_SIZE, GAP, ART_SIZE, ART_SIZE))
			clicked_slot = @sections*2 + 1
		elsif(area_clicked(GAP, GAP*2+ART_SIZE, ART_SIZE, ART_SIZE))
			clicked_slot = @sections*2 + 2
		elsif(area_clicked(GAP*2+ART_SIZE, GAP*2+ART_SIZE, ART_SIZE, ART_SIZE))
			clicked_slot = @sections*2 + 3
		else
			return
		end

		#if selecting slot with no album, retain the previous album_selected
		if(@albums[clicked_slot] != nil)
			@album_slot = clicked_slot
			@album_selected = @albums[clicked_slot]
		end
	end

	#controls which section to display (up and down)
	def arrow_clicked()
		if (@albums.length <= 4)
			max_sections = 0
		else
			max_sections = ((@albums.length-3)/2).ceil
		end

		if(area_clicked(GAP*3+ART_SIZE*2, GAP, 100, 100) && @sections > 0)
			@sections -= 1
		elsif(area_clicked(GAP*3+ART_SIZE*2, GAP*2+ART_SIZE*2-100, 100, 100) && @sections < max_sections)
			@sections += 1
		end
	end

	#as long as an album is selected, a track can be clicked
	def track_clicked()
		if(@album_slot == nil) then return end

		current_album = @albums[@album_slot]
		idx = 0
		count = current_album.tracks.length
		while (idx < count)
			if(area_clicked(SIDE_MENU+GAP, 170+idx*25, 1800, 20))
				@selected_song_track = current_album.tracks[idx]
				play_current_track()
			end
			idx += 1
		end
	end

	#as long as a song is selected, change between playing and paused
	def play_pause_clicked()
		if(@selected_song_track == nil) then return end
		if(area_clicked(GAP*3+ART_SIZE*2, GAP+ART_SIZE-50, 100, 100))
			if(@currently_playing)
				pause_current_track()
			else
				continue_current_track()
			end
		end
	end

	# Detects if a 'mouse sensitive' area has been clicked on
	def area_clicked(leftX, topY, width, height)
		if ((mouse_x > leftX and mouse_x < leftX+width) and (mouse_y > topY and mouse_y < topY+height))
			true
		else
			false
		end
	end

	#displays a limited amount of tracks depending on how many tracks stored in array field
	def display_tracks(album)
		idx = 0
		count = album.tracks.length
		if (count == 0)
			@font.draw_text("This Album Has No Tracks", SIDE_MENU+GAP, 300, ZOrder::TXT)
		end
		while (idx < count || idx > MAX_SONGS_PER_ALBUM)
			display_track(album.tracks[idx].name, idx)
			idx += 1
		end
	end

	#display track box and font
	def display_track(title, ypos)
		#if no song selected or if the parsed song title does not equal the currently selected song (draw normal)
		if (@selected_song_track == nil || title != @selected_song_track.name)
			draw_rect(SIDE_MENU+GAP, 170+ypos*25, 1800, 20, 0xff_404040, ZOrder::ICON)
			@track_font.draw_text(ypos+1, SIDE_MENU+GAP*2-15, 170+ypos*25, ZOrder::TXT, 1.0, 1.0, Gosu::Color::WHITE)
			@track_font.draw_text(title, SIDE_MENU+GAP*3, 170+ypos*25, ZOrder::TXT, 1.0, 1.0, Gosu::Color::WHITE)
		else
			#if playing (draw dark and outward)
			if(@currently_playing == true)
				draw_rect(SIDE_MENU+GAP-30, 170+ypos*25, 1800, 20, 0xff_202020, ZOrder::ICON)
			#else (draw light and outward)
			else
				draw_rect(SIDE_MENU+GAP-30, 170+ypos*25, 1800, 20, 0xff_404040, ZOrder::ICON)
			end
			@track_font.draw_text(ypos+1, SIDE_MENU+GAP*2-45, 170+ypos*25, ZOrder::TXT, 1.0, 1.0, Gosu::Color::WHITE)
			@track_font.draw_text(title, SIDE_MENU+GAP*3-30, 170+ypos*25, ZOrder::TXT, 1.0, 1.0, Gosu::Color::WHITE)
		end
	end

	def play_current_track()
		#@song = Gosu::Song.new(track.location) ***
		#@song.play(false)
		@currently_playing = true
		print "Playing: "
		puts @selected_song_track.name
	end

	def pause_current_track()
		@currently_playing = false
		print "Pause: "
		puts @selected_song_track.name
	end

	def continue_current_track()
		@currently_playing = true
		print "Continue Playing: "
		puts @selected_song_track.name
	end
end

# Reads in and returns an array of albums from the given file
def read_albums(file_name)
	music_file = File.new(file_name, "r")
	count = music_file.gets().to_i()
	idx = 0
	while (idx < count)
		album = read_album(music_file)
		@albums << album
		idx += 1
	end
	music_file.close()
end

# Reads in and returns a single album from the given file, with all its tracks
def read_album(music_file)

	# read in all the Album's fields/attributes including all the tracks
	album_artist = music_file.gets()
	album_title = music_file.gets()
	album_art_file = music_file.gets().chomp
	album_genre = music_file.gets().to_i
	album_tracks = read_tracks(music_file)

	album = Album.new(album_title, album_artist, album_genre, album_tracks, album_art_file)
	return album
end

# Returns an array of tracks read from the given file

def read_tracks(music_file)
  count = music_file.gets().to_i()
  tracks = Array.new()
  # Put a while loop here which increments an index to read the tracks
  idx = 0;
  while (idx < count)
    track = read_track(music_file)
    tracks << track
    idx = idx + 1
  end
  tracks.sort_by { |t| [t.location]} #For every track t, sort by location
  return tracks
end

# Reads in and returns a single track from the given file

def read_track(music_file)
	name = music_file.gets()
	location = music_file.gets()
	return Track.new(name, location)
end

# Takes in an array of albums and prints them to the terminal
def print_albums(album)
	idx = 0
	count = album.length
	while (idx < count)
	  print_album(album[idx])
	  idx += 1;
	end
end

# Takes a single album and prints it to the terminal along with all its tracks
def print_album(album)
	# print out all the albums fields/attributes
	# Complete the missing code.
	puts(album.artist)
	puts(album.title)
	puts('Genre is ' + album.genre.to_s)
    puts(GENRE_NAMES[album.genre])
 	print_tracks(album.tracks)
end

# Takes an array of tracks and prints them to the terminal
def print_tracks(tracks)
	# print all the tracks use: tracks[x] to access each track.
  idx = 0
  count = tracks.length
  while (idx < count)
    print_track(tracks[idx])
    idx = idx + 1;s
  end
end

# Takes a single track and prints it to the terminal
def print_track(track)
  puts(track.name)
  puts(track.location)
end

MusicPlayerMain.new.show if __FILE__ == $0