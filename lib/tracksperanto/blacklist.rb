class Tracksperanto::Blacklist
  
  # Prevent totally unsupported formats from being used
  def self.raise_if_format_unsupported(judging_from_file_path)
    extension = File.extname(judging_from_file_path).downcase
    formats_and_extensions.each_pair do | matcher, message |
      raise Tracksperanto::UnsupportedFormatError, message if matcher.is_a?(String) && extension == matcher
      raise Tracksperanto::UnsupportedFormatError, message if matcher.is_a?(Regexp) && extension =~ matcher
    end
  end
  
  def self.formats_and_extensions
    {
      '.ma' =>  'We cannot import Maya ASCII files directly. For processing Maya Live tracks export them from Maya.',
      '.mb' => 'We cannot import Maya scene files directly. For processing Maya Live tracks export them from Maya.',
      /\.(mov|avi|xvid|mp4)$/ => 'Tracksperanto is not a tracking application, it converts tracks. We do not support movie file formats.',
      /\.(r3d)$/ => 'Tracksperanto is not a tracking application, it converts tracks. We do not support RAW file formats.',
      /\.(dpx|tif(f?)|jp(e?)g|png|gif|tga)$/ => 'Tracksperanto is not a tracking application, it converts tracks. We do not support image file formats.',
      '.sni' => 'We cannot read binary SynthEyes scene files. Export your tracks as one of the supported formats.',
      /\.(pfb|pfmp|ptp)/ => 'We cannot directly open PFTrack projects, export .2dt files instead',
      '.mmf' => 'We cannot directly open MatchMover projects, please export your tracks as .rz2 instead',
      /\.(doc(x?)|xls(x?)|ppt(x?))/ => 'You really think we can process Microsoft Office files? You need a drink.',
      /\.(abc|fbx)$/ => 'We cannot import 3D scenes such as Alembic or FBX.',
      '.3de' => 'We cannot handle 3DE project files directly, please export your 2D tracks in a compatible format instead.',
      '.bpj' => "We cannot handle Boujou projects directly, please export your feature tracks from Boujou as a text file",
      '.py' => 'We cannot handle Python scripts - please export your 2D tracks in a compatible format instead.',
      '.ascii' => 'We cannot handle ascii Flame exports. Just save your setup and upload it - it will work fine.',
      '.c4d' => 'We cannot CINEMA 4D scenes. Consider using another workflows.',
    }
  end
end