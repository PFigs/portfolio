function str = latexref(label, varargin)
%LATEXREF returns a latex reference string
%   This string can also be written to a file if a file descriptor is
%   passed to it.
%
%   NOTE: No space is given before or after the string
%
%   INPUT
%   LABEL    - Reference label
%   VARARGIN - File descriptor
%
%   OUTPUT
%   STR - String or fprintf status
%
%   USAGE
%       latexref('fig:building') % returns string with a reference to the
%                                % given label "fig:building"
%
%
%       latexref('fig:building',FID) % writes reference to the given label
%                                    % "fig:building" to FID
%   
%   Pedro Silva, Instituto Superior Tecnico, May 2012

    if nargin == 1
        str = sprintf('\\\\ref{%s}',label); % extra / needed
    else
        str = fprintf(varargin{1},'\\ref{%s}',label);
    end
end