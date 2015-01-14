/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.flexunit.ant.tasks;

import java.io.File;

import org.apache.tools.ant.BuildException;
import org.apache.tools.ant.Project;
import org.apache.tools.ant.taskdefs.Java;
import org.apache.tools.ant.types.FilterSet;
import org.apache.tools.ant.types.FilterSetCollection;
import org.apache.tools.ant.types.Commandline.Argument;
import org.apache.tools.ant.types.resources.FileResource;
import org.apache.tools.ant.types.resources.URLResource;
import org.apache.tools.ant.util.ResourceUtils;
import org.flexunit.ant.LoggingUtil;
import org.flexunit.ant.tasks.configuration.CompilationConfiguration;
import org.flexunit.ant.tasks.types.LoadConfig;
import sun.rmi.runtime.Log;

public class Compilation
{
   private final String FLEX_APPLICATION_CLASS = "Application";
   private final String AIR_APPLICATION_CLASS = "WindowedApplication";
   private final String CI_LISTENER = "CIListener";
   private final String AIR_CI_LISTENER = "AirCIListener";
   private final String TESTRUNNER_TEMPLATE = "TestRunner.template";
   private final String TESTRUNNER_FILE = "TestRunner.as";
   private final String MXMLC_CLI_RELATIVE_PATH = "lib/mxmlc-cli.jar";
   private final String FRAMEWORKS_RELATIVE_PATH = "frameworks";
   private final String SWF_FILENAME = "TestRunner.swf";
   
   private CompilationConfiguration configuration;
   private Project project;
   private String mxmlcCliPath;
   
   public Compilation(Project project, CompilationConfiguration configuration)
   {
      this.project = project;
      this.configuration = configuration;
      mxmlcCliPath = configuration.getFlexHome().getAbsolutePath() + File.separatorChar + MXMLC_CLI_RELATIVE_PATH;
   }
   
   public File compile() throws BuildException
   {
      configuration.log();

      File runnerFile = generateTestRunnerFromTemplate(configuration.getWorkingDir());
      File finalFile = new File(configuration.getWorkingDir().getAbsolutePath() + File.separatorChar + SWF_FILENAME);
      
      Java compilationTask = createJavaTask(runnerFile, finalFile);
      LoggingUtil.log("Compiling test classes: [" + configuration.getTestSources().getCanonicalClasses(", ") + "]", true);
      LoggingUtil.log(compilationTask.getCommandLine().describeCommand());
      
      if(compilationTask.executeJava() != 0)
      {
         throw new BuildException("Compilation failed:\n" + project.getProperty("MXMLC_ERROR"));
      }
      
      return finalFile;
   }
   
   private File generateTestRunnerFromTemplate(File workingDir) throws BuildException
   {
      try
      {
         String ciListener = configuration.getPlayer().equals("flash") ? CI_LISTENER : AIR_CI_LISTENER;
         
         File runner = new File(workingDir.getAbsolutePath() + File.separatorChar + TESTRUNNER_FILE);
         
         //Template location in JAR
         URLResource template = new URLResource(getClass().getResource("/" + TESTRUNNER_TEMPLATE));
         
         //Create tokens to filter
         FilterSet filters = new FilterSet();
         filters.addFilter("CI_LISTENER_CLASS", ciListener);
         filters.addFilter("IMPORT_REFS", configuration.getTestSources().getImports());
         filters.addFilter("CLASS_REFS", configuration.getTestSources().getClasses());

         //Copy descriptor template to SWF folder performing token replacement
         ResourceUtils.copyResource(
            template,
            new FileResource(runner),
            new FilterSetCollection(filters),
            null,
            true,
            false,
            null,
            null,
            project
         );
         
         LoggingUtil.log("Created test runner at [" + runner.getAbsolutePath() + "]");
         
         return runner;
      }
      catch (Exception e)
      {
         throw new BuildException("Could not create test runner from template.", e);
      }
   }
   
   private Java createJavaTask(File runnerFile, File finalFile)
   {
      Java task = new Java();
      task.setFork(true);
      task.setFailonerror(true);
      task.setJar(new File(mxmlcCliPath));
      task.setProject(project);
      task.setDir(project.getBaseDir());
      task.setMaxmemory("256M"); //MXMLC needs to eat
      task.setErrorProperty("MXMLC_ERROR");
      
      if(configuration.getPlayer().equals("air"))
      {
         Argument airConfigArgument = task.createArg();
         airConfigArgument.setValue("+configname=air");
      }
      
      Argument outputFile = task.createArg();
      outputFile.setLine("-o \"" + finalFile.getAbsolutePath() + "\"");
      
      Argument sourcePath = task.createArg();
      sourcePath.setLine("-source-path " + configuration.getSources().getPathElements(" ") + " " + configuration.getTestSources().getPathElements(" "));
      
      determineLibraryPath(task);
      determineLoadConfigArgument(task);
       
      Argument debug = task.createArg();
      debug.setLine("-debug=" + configuration.getDebug());
      
      Argument mainFile = task.createArg();
      mainFile.setValue(runnerFile.getAbsolutePath());
      
      return task;
   }
   
   
   private void determineLoadConfigArgument(Java java)
   {
       Argument argument = java.createArg();
       LoadConfig config = configuration.getLoadConfig();
       if(config != null) argument.setLine(config.getCommandLineArgument());
       else argument.setLine("-load-config=" + configuration.getFlexHome() + "/frameworks/flex-config.xml");
   }

   private void determineLibraryPath(Java java)
   {
       if(!configuration.getLibraries().getPathElements(" -library-path+=").isEmpty())
       {
           Argument libraryPath = java.createArg();
           libraryPath.setLine("-library-path+=" + configuration.getLibraries().getPathElements(" -library-path+="));
       }
   }
   
}
