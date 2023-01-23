if defined?(AssetSync)
  Rake::Task['webpacker:compile'].enhance do
    Rake::Task["assets:sync"].invoke
  end
end

# to enable assets syn plase full teh ENV for :
# ASSET_HOST_NAME=""
# S3_ACCESS_KEY=""
# S3_SECRET_KEY=""
# S3_REGION=""
# S3_MEDIA_BUCKET=""
