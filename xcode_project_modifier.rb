#!/usr/bin/env ruby

require 'xcodeproj'

class XcodeProjectModifier
  def initialize(project_path)
    @project_path = project_path
    @project = Xcodeproj::Project.open(project_path)
    @main_target = @project.targets.first
    @test_target = @project.targets.find { |target| target.name.include?('Tests') }
  end

  def add_file(file_path, group_path = nil)
    # Convert to absolute path first, then make relative to project
    absolute_file_path = File.absolute_path(file_path)
    absolute_project_dir = File.absolute_path(@project.project_dir)
    relative_path = Pathname.new(absolute_file_path).relative_path_from(Pathname.new(absolute_project_dir))
    
    # Find or create the group
    group = find_or_create_group(group_path) if group_path
    group ||= @project.main_group
    
    # Check if file already exists in project
    existing_file = @project.files.find { |f| f.path == relative_path.to_s }
    if existing_file
      puts "File #{relative_path} already exists in project"
      return false
    end
    
    # Add the file reference
    file_ref = group.new_file(relative_path)
    
    # Add to build phase if it's a Swift file
    if file_path.end_with?('.swift')
      # Determine target based on file path
      target = file_path.include?('Tests') ? @test_target : @main_target
      if target
        target.source_build_phase.add_file_reference(file_ref)
        puts "Added #{relative_path} to project and #{target.name} target build phase"
      else
        puts "Added #{relative_path} to project (no suitable target found)"
      end
    else
      puts "Added #{relative_path} to project"
    end
    
    save_project
    true
  end

  def remove_file(file_path)
    # Convert to absolute path first, then make relative to project
    absolute_file_path = File.absolute_path(file_path)
    absolute_project_dir = File.absolute_path(@project.project_dir)
    relative_path = Pathname.new(absolute_file_path).relative_path_from(Pathname.new(absolute_project_dir))
    
    # Find the file reference
    file_ref = @project.files.find { |f| f.path == relative_path.to_s }
    
    unless file_ref
      puts "File #{relative_path} not found in project"
      return false
    end
    
    # Remove from build phase if it's in one
    @main_target.source_build_phase.remove_file_reference(file_ref)
    @test_target&.source_build_phase&.remove_file_reference(file_ref)
    
    # Remove the file reference
    file_ref.remove_from_project
    
    puts "Removed #{relative_path} from project"
    save_project
    true
  end

  def list_files(pattern = nil)
    files = @project.files.map(&:path)
    if pattern
      files = files.select { |f| f.match(pattern) }
    end
    files.sort
  end

  private

  def find_or_create_group(group_path)
    group_names = group_path.split('/')
    current_group = @project.main_group
    
    group_names.each do |group_name|
      found_group = current_group.children.find { |child| 
        child.is_a?(Xcodeproj::Project::Object::PBXGroup) && child.name == group_name 
      }
      
      if found_group
        current_group = found_group
      else
        current_group = current_group.new_group(group_name)
      end
    end
    
    current_group
  end

  def save_project
    @project.save
    puts "Project saved"
  end
end

# Command line interface
if __FILE__ == $0
  if ARGV.length < 2
    puts "Usage: #{$0} <command> <file_path> [group_path]"
    puts "Commands:"
    puts "  add <file_path> [group_path] - Add file to project"
    puts "  remove <file_path>           - Remove file from project"
    puts "  list [pattern]               - List files in project"
    exit 1
  end

  project_path = 'ShoeCycle.xcodeproj'
  modifier = XcodeProjectModifier.new(project_path)

  command = ARGV[0]
  file_path = ARGV[1]
  group_path = ARGV[2]

  case command
  when 'add'
    modifier.add_file(file_path, group_path)
  when 'remove'
    modifier.remove_file(file_path)
  when 'list'
    pattern = ARGV[1]
    files = modifier.list_files(pattern)
    puts "Files in project:"
    files.each { |f| puts "  #{f}" }
  else
    puts "Unknown command: #{command}"
    exit 1
  end
end